# Konnect Ops Demo <!-- omit in toc -->

> Warning! This project is currently under active development, and all aspects are subject to change. Use at your own risk!

A local demo showcasing the utilization of [Terraform](https://www.terraform.io/) and [Helm](https://helm.sh/) for the provisioning of Konnect Resources and deployment of Kong Data Planes (DPs) within Kubernetes (K8s) environments.

The demo environment is configured with [MinIO](https://min.io/) serving as a Terraform backend, and [HashiCorp Vault](https://www.vaultproject.io/) utilized for the secure storage of credentials and sensitive information.

In addition, the demo environment includes an example of Kong State file management, as part of an APIOps workflow.

The Continuous Integration/Continuous Deployment (CI/CD) process employs the execution of [GitHub Actions](https://github.com/features/actions) locally through the utilization of [Act](https://github.com/nektos/act).

## Table of Contents <!-- omit in toc -->

<!-- TOC -->
- [Useful links](#useful-links)
- [Prerequisites](#prerequisites)
- [Prepare the demo environment](#prepare-the-demo-environment)
- [Build Kong Golden Image](#build-kong-golden-image)
  - [Flow](#flow)
  - [Run the Build workflow](#run-the-build-workflow)
- [Provision Konnect resources](#provision-konnect-resources)
  - [Centralised approach](#centralised-approach)
    - [Flow](#flow-1)
    - [Run the Provisioning workflow](#run-the-provisioning-workflow)
  - [Federated approach (Teams onboarding)](#federated-approach-teams-onboarding)
    - [Flow](#flow-2)
    - [Run the Team Onboarding workflow](#run-the-team-onboarding-workflow)
- [Deploy Data Planes](#deploy-data-planes)
- [Promoting API configuration (State file management)](#promoting-api-configuration-state-file-management)
  - [Flow](#flow-3)
  - [Run the workflow](#run-the-workflow)
<!-- /TOC -->

## Useful links

- [Kong Konnect Terraform Provider](https://github.com/Kong/terraform-provider-konnect)
- [Kong GO APIOps](https://github.com/Kong/go-apiops)
- [Deck Commands](https://docs.konghq.com/deck/latest/#deck-commands)

## Prerequisites
- [Docker](https://www.docker.com/) and [docker compose](https://docs.docker.com/compose/)
- [Kind](https://kind.sigs.k8s.io/)

## Prepare the demo environment

Services:
- MinIO: http://localhost:9000
- Hashicorp Vault: http://localhost:8300
- Local Docker registry: http://localhost:5000

To spin-up and prepare your local environment, execute: 

```bash
$ make prepare
```

When preparing the demo environment for the first time, you will be prompted
to provide your `konnect access token`, `s3 access key` and `s3 access secret`.

To get your `konnect access token`, login to your Konnect organization, navigate to the `Personal Access Tokens` page and click `Generate Token`.

![Konnect](./images/konnect_pat.png)

To create your `s3 access key` and `s3 access secret`: 
1. Open `Minio Console` at http://localhost:9000. 
2. Login using `minio-root-user`, `minio-root-password` as username and password.
3. Go to `Access Keys`
4. `Create Access Key`

![Minio Console](./images/minio.png)


## Build Kong Golden Image

### Flow

```mermaid
graph LR;
    A[Download Kong Package] --> B[Install custom plugins];
    B --> C[Add Certificates];
    C --> D[Build];
    D --> E[Scan];
    E --> F[Test];
    F -.-> G[Publish];
```

### Run the Build workflow

```bash
$ act --input image_repo=myrepo/kong --input image_tag=latest workflow_call -W .github/workflows/build-image.yaml    
```

***Input parameters***

| Name                     | Description                                                | Required | Default        |
| ------------------------ | ---------------------------------------------------------- | -------- | -------------- |
| docker_registry          | The Docker registry to push the image to                   | No       | localhost:5000 |
| image_repo               | The repository the docker image will be pushed             | Yes      | -              |
| image_tag                | The tag of the docker image                                | Yes      | -              |
| kong_version             | The kong gateway ee version to base the resulting image on | No       | 3.7.0.0        |
| continue_on_scan_failure | Continue the workflow even if the security scan fails      | No       | true           |

## Provision Konnect resources

In this demo, there are two documented approaches for provisioning resources in Konnect.

1. **Centralised**: A central Platform team manages all Konnect resources
2. **Federated**: Every team manages their own Konnect resources


### Centralised approach

The provisioning and deployment process is based on predefined resources. You can find an example in `examples/platformops/centralised/resources.json`.

***Resources Configuration Example***

```json
{
  "metadata": {
    "format_version": "1.0.0",
    "type": "konnect::resources",
    "plan": "centralised",
    "region": "eu",
    "name": "rsgrpeu",
    "description": "EU resource group"
  },
  "resources": {
    "teams": [
      {
        "name": "platform",
        "description": "Platform Team is responsible for the development and maintenance of the APIM platform."
      },
      {
        "name": "team1",
        "description": "Team 1 is responsible for the development and maintenance of their respective APIs."
      },
      {
        "name": "team2",
        "description": "Team 2 is responsible for the development and maintenance of their respective APIs."
      }
    ],
    "system_accounts": [
      {
        "name": "platform_system_account",
        "description": "System account for Platform Team",
        "team_memberships": [
          "platform"
        ],
        "roles": [
          {
            "entity_type_name": "Control Planes",
            "role_name": "Admin",
            "entity_name": "*"
          }
        ]
      },
      {
        "name": "team1_system_account",
        "description": "System account for Team 1",
        "team_memberships": [
          "team1"
        ],
        "roles": [
          {
            "entity_type_name": "Control Planes",
            "role_name": "Admin",
            "entity_name": "cp1"
          },
          {
            "entity_type_name": "Control Planes",
            "entity_region": "eu",
            "role_name": "Admin",
            "entity_name": "cp2"
          },
          {
            "entity_type_name": "Control Planes",
            "entity_region": "eu",
            "role_name": "Admin",
            "entity_name": "cp3"
          }
        ]
      },
      {
        "name": "team2_system_account",
        "description": "System account for Team 2",
        "team_memberships": [
          "team2"
        ],
        "roles": [
          {
            "entity_type_name": "Control Planes",
            "entity_region": "eu",
            "role_name": "Admin",
            "entity_name": "cp4"
          },
          {
            "entity_type_name": "Control Planes",
            "entity_region": "eu",
            "role_name": "Admin",
            "entity_name": "cp5"
          },
          {
            "entity_type_name": "Control Planes",
            "entity_region": "eu",
            "role_name": "Admin",
            "entity_name": "cp6"
          }
        ]
      }
    ],
    "control_planes": [
      {
        "name": "cp1",
        "description": "Demo Control Plane 1",
        "labels": {
          "apigroup": "apigroup1"
        }
      },
      {
        "name": "cp2",
        "description": "Demo Control Plane 2",
        "labels": {
          "apigroup": "apigroup2"
        }
      },
      {
        "name": "cp3",
        "description": "Demo Control Plane 3",
        "labels": {
          "apigroup": "apigroup3"
        }
      },
      {
        "name": "cp4",
        "description": "Demo Control Plane 4",
        "labels": {
          "apigroup": "apigroup4"
        }
      },
      {
        "name": "cp5",
        "description": "Demo Control Plane 5",
        "labels": {
          "apigroup": "apigroup5"
        }
      },
      {
        "name": "cp6",
        "description": "Demo Control Plane 6",
        "labels": {
          "apigroup": "apigroup6"
        }
      }
    ],
    "control_plane_groups": [
      {
        "name": "cp_grp1",
        "description": "Demo Control Plane Group 1",
        "labels": {
          "cloud": "gcp"
        },
        "members": [
          "cp1"
        ]
      },
      {
        "name": "cp_grp2",
        "description": "Demo Control Plane Group 2",
        "labels": {
          "cloud": "gcp"
        },
        "members": [
          "cp2"
        ]
      },
      {
        "name": "cp_grp3",
        "description": "Demo Control Plane Group 3",
        "labels": {
          "cloud": "on-prem"
        },
        "members": [
          "cp1",
          "cp4",
          "cp5"
        ]
      },
      {
        "name": "cp_grp4",
        "description": "Demo Control Plane Group 4",
        "labels": {
          "cloud": "aws"
        },
        "members": [
          "cp1"
        ]
      },
      {
        "name": "cp_grp5",
        "description": "Demo Control Plane Group 5",
        "labels": {
          "cloud": "aws"
        },
        "members": [
          "cp6"
        ]
      }
    ]
  }
}
```

The above configuration will result in the following high level setup

```mermaid
graph TD;
  subgraph Konnect
      A[Team 1]
      S[Platform Team]
      B[Team 2]
      C[CP 1]
      D[CP 2]
      E[CP 3]
      F[CP 4]
      G[CP 5]
      H[CP 6]
    end

    subgraph GCP
      direction RL
        I[ Control Plane Group 1]
        J[ Control Plane Group 2]
        N[Kong DP]
        O[Kong DP]
    end


    subgraph On Prem
      direction RL
        K[ Control Plane Group 3]
        P[Kong DP]
    end

    subgraph AWS
      direction RL
        L[ Control Plane Group 4]
        M[ Control Plane Group 5]
        Q[Kong DP]
        R[Kong DP]
    end
    S --> C
    S --> D
    S --> E
    S --> F
    S --> H
    S --> G
    A --> C
    A --> D
    A --> E
    B --> F
    B --> G
    B --> H
    C -.-> K
    E -.-> L
    F -.-> K
    G -.-> K
    H -.-> M
    D -.-> J
    C -.-> I
    I --> N
    J --> O
    K --> P
    L --> Q
    M --> R

```

#### Flow

```mermaid
graph TD;
    A[Create Teams]
    B[Provision Team CPs]
    C[Create CP Groups]
    D[Add DP Certificates]
    E[Assign CPs to CP Groups]
    F[Create System Accounts]
    G[Assign Team memberships] --> H[Configure CP Role Assignments]
    J[Create System Account Tokens] --> I[Store Tokens in Vault]

    A --> B
    B --> D
    B -.-> C
    C -.-> D
    C -.-> E
    B --> F
    F --> G
    F --> J
```

#### Run the Provisioning workflow

To provision centralised Konnect resources, execute the following command: 

```bash
$ act --input config_file=examples/platformops/centralised/resources.json -W .github/workflows/provision-konnect.yaml 
```

***Input Parameters***

| Name        | Description                                            | Required | Default               |
| ----------- | ------------------------------------------------------ | -------- | --------------------- |
| config_file | The path to the resources config file                  | Yes      | -                     |
| vault_addr  | The address of the HashiCorp Vault server              | No       | http://localhost:8300 |
| action      | The action to perform. Either `provision` or `destroy` | No       | `provision`           |
| environment | The environment to provision                           | No       | `local`               |

To destroy the resources in Konnect:

```bash
$ act --input config_file=examples/platformops/centralised/resources.json --input action=destroy -W .github/workflows/provision-konnect.yaml         
```

### Federated approach (Teams onboarding)

The provisioning and deployment process is based on predefined resources. You can find examples in `examples/platformops/federated`.

***Resources Configuration Example***

```json
{
  "metadata": {
      "format_version": "1.0.0",
      "type": "konnect::team",
      "plan": "federated",
      "region": "eu",
      "name": "kronos",
      "description": "Kronos team is building IaC services in the EU region"
  },
  "resources": [
    {
      "type": "konnect::control_plane",
      "name": "kronos_cp_dev",
      "description": "Control plane 1",
      "labels": {
        "env": "dev"
      }
    },
    {
      "type": "konnect::control_plane",
      "name": "kronos_cp_acc",
      "description": "Control plane 1",
      "labels": {
        "env": "acc"
      }
    },
    {
      "type": "konnect::control_plane",
      "name": "kronos_cp_prd",
      "description": "Control plane 1",
      "labels": {
        "env": "prd"
      }
    }
  ]
}
```

The above configuration will result in the following high level setup

```mermaid
graph TD;
  subgraph Konnect
    A[Team Kronos]
    B["
    Control Plane
    kronos_cp_dev
    "]
    C["
    Control Plane
    kronos_cp_acc
    "]
    D["
    Control Plane
    kronos_cp_prd
    "]

    E["
    System Account
    npa_kronos_kronos_cp_dev
    "]

    F["
    System Account
    npa_kronos_kronos_cp_acc
    "]

    G["
    System Account
    npa_kronos_kronos_cp_prd
    "]
  end

  A --> E -.-> |CP Admin|B
  A --> F -.-> |CP Admin|C
  A --> G -.-> |CP Admin|D

```

#### Flow

```mermaid
graph LR;
  A[Create Team]
  B[Create CPs]
  C[Add Certificates to CPs]
  D["
  Create System Accounts
  Access Tokens
  Team membership
  CP Admin role
  "]
  E[Store Credentials in Vault]

  A --> B --> C --> D --> E
```

#### Run the Team Onboarding workflow

To onboard the example teams in Konnect, execute the following command: 

```bash
## Onboard team Kronos
$ act --input config_file=examples/platformops/federated/kronos-team.json \
  -W .github/workflows/provision-konnect-federated.yaml 

# Onboard team Tiger
$ act --input config_file=examples/platformops/federated/tiger-team.json \
  -W .github/workflows/provision-konnect-federated.yaml 
```

To offboard the teams, you can execute the same commands with `--input action=destroy`.

```bash
## Offboard team Kronos
$ act --input config_file=examples/platformops/federated/kronos-team.json \
  --input action=destroy
  -W .github/workflows/provision-konnect-federated.yaml 

```

***Input Parameters***

| Name        | Description                                            | Required | Default               |
| ----------- | ------------------------------------------------------ | -------- | --------------------- |
| config_file | The path to the resources config file                  | Yes      | -                     |
| vault_addr  | The address of the HashiCorp Vault server              | No       | http://localhost:8300 |
| action      | The action to perform. Either `provision` or `destroy` | No       | `provision`           |
| environment | The environment to provision                           | No       | `local`               |

## Deploy Data Planes

After provisioning, you can deploy the Kong DPs to your local K8s:

```bash
$ act --input control_plane_name=<cp_name> \
      --input system_account=<sa_name> \
      -W .github/workflows/deploy-dp.yaml
```

***Input Parameters***

| Name               | Description                                               | Required | Default                   |
| ------------------ | --------------------------------------------------------- | -------- | ------------------------- |
| namespace          | The Kubernetes namespace where the dps will be deployed   | No       | kong                      |
| kong_image_repo    | The repository of the Kong Docker image                   | No       | kong/kong-gateway         |
| kong_image_tag     | The tag of the Kong Docker image                          | No       | 3.7.0.0                   |
| vault_addr         | The address of the HashiCorp Vault server                 | No       | http://localhost:8300     |
| control_plane_name | The name of the control plane to deploy the data plane to | Yes      | -                         |
| system_account    | The system account to use for authentication             | Yes      | -                         |
| konnect_server_url | Konnect server URL                                        | No       | https://eu.api.konghq.com |
| action             | Action to perform. Can be `deploy` or `destroy`           | No       | `deploy`                  |

## Promoting API configuration (State file management)

This is the process of configuring Kong to proxy traffic to upstream APIs based on a provided Open API Specification (OAS).

### Flow

```mermaid
graph LR;
  A[OAS]
  B[Patch OAS]
  C[Lint OAS]
  D["Deck Ops
    --------------
    - openapi2kong
    - file merge
    - namespace
    - patch
    ...
  "]
  E[Validate future state
  --------------
  deck file validate
  ]
  F["Backup current state
  --------------
  deck gateway dump"]
  G[Diff current vs future state
  --------------
  deck gateway diff
  ]
  H[
  Archive artifacts
  --------------
  - linting results
  - test results
  - diff results
  - current state backup
  ]
  I[Sync future state
  --------------
  deck gateway sync
  ]

  A --> B --> C --> D --> E --> F --> G --> H --> I
```

### Run the workflow

After you have provisioned the Konnect resources and a local Kong DP is up and running:

```bash
$ act --input openapi_spec=examples/apiops/openapi.yaml \
    --input control_plane_name=<control_plane_name> \
    --input system_account=<system_account_name>  \
    -W .github/workflows/promote-api.yaml
```

***Input Parameters***

| Name               | Description                                             | Required | Default                   |
| ------------------ | ------------------------------------------------------- | -------- | ------------------------- |
| openapi_spec       | Path to the OpenAPI Specification file                  | Yes      | -                         |
| vault_addr         | The address of the HashiCorp Vault server               | No       | http://localhost:8300     |
| control_plane_name | The name of the control plane to sync the configuration | Yes      | -                         |
| system_account    | The Konnect system account to use for authentication    | Yes      | -                         |
| konnect_server_url | Konnect server URL                                      | No       | https://eu.api.konghq.com |

