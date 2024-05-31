# Konnect Platform Ops Demo

A local demo showcasing the utilization of [Terraform](https://www.terraform.io/) and [Helm](https://helm.sh/) for the provisioning of Konnect Control Planes (CPs) and deployment of Kong Data Planes (DPs) within Kubernetes (K8s) environments.

The demo environment is configured with [MinIO](https://min.io/) serving as a Terraform backend, and [HashiCorp Vault](https://www.vaultproject.io/) utilized for the secure storage of credentials and sensitive information.

The Continuous Integration/Continuous Deployment (CI/CD) process employs the execution of [GitHub Actions](https://github.com/features/actions) locally through the utilization of [Act](https://github.com/nektos/act).

# Prerequisites
- [Docker](https://www.docker.com/) and [docker compose](https://docs.docker.com/compose/)
- A functional local Kubernetes (k8s) environment
- [Terraform](https://www.terraform.io/)
- [Helm](https://helm.sh/)
- [`act` - Local GitHub Actions Runner](https://github.com/nektos/act)
- [Hashicorp Vault CLI](https://developer.hashicorp.com/vault/install)

