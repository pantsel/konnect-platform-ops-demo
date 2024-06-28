resource "konnect_gateway_control_plane" "tfgatewaycontrolplane" {
  for_each = { for control_plane in local.control_planes : control_plane.name => control_plane }
  
  name         = each.value.name
  description  = each.value.description
  cluster_type  = "CLUSTER_TYPE_CONTROL_PLANE"
  cloud_gateway = true
  auth_type     = "pinned_client_certs"
  proxy_urls    = []
}

data "konnect_cloud_gateway_provider_account_list" "tfcloudgatewayprovideraccountlist" {
  page_number = 1
  page_size   = 1
}

resource "konnect_cloud_gateway_network" "tfcloudgatewaynetwork" {
  name   = "Terraform Network"
  region = "us-east-2"
  availability_zones = [
    "use2-az1",
    "use2-az2",
    "use2-az3"
  ]

  firewall = {
    allowed_cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  cidr_block      = "192.168.0.0/16"
  ddos_protection = false

  cloud_gateway_provider_account_id = data.konnect_cloud_gateway_provider_account_list.tfcloudgatewayprovideraccountlist.data[0].id
}

resource "konnect_cloud_gateway_configuration" "tfcloudgatewayconfiguration" {
  for_each = { for cloud_gateway in local.cloud_gateways : cloud_gateway.name => cloud_gateway }
  
  api_access        = "private+public"
  control_plane_geo = "us"
  control_plane_id  = { for control_plane in konnect_gateway_control_plane.tfgatewaycontrolplane : lower(control_plane.name) => control_plane.id}[each.value.control_plane_name]
  dataplane_groups = [
    {
      provider = "aws"
      region   = each.value.region
      autoscale = {
        configuration_data_plane_group_autoscale_autopilot = {
          kind     = "autopilot"
          base_rps = 10
          max_rps  = 100
        }

        #configuration_data_plane_group_autoscale_static = {
        #  kind                = "static"
        #  instance_type       = "small"
        #  requested_instances = 1
        #}
      }
      cloud_gateway_network_id = konnect_cloud_gateway_network.tfcloudgatewaynetwork.id
    },
  ]
  version = "3.6"
}

resource "konnect_cloud_gateway_custom_domain" "tfcloudgatewaycustomdomain" {
  for_each = { for cloud_gateway in local.cloud_gateways : cloud_gateway.name => cloud_gateway }

  control_plane_geo = "us"
  control_plane_id  = { for control_plane in konnect_gateway_control_plane.tfgatewaycontrolplane : lower(control_plane.name) => control_plane.id}[each.value.control_plane_name]
  domain            = "cgw-demo.schenkeveld.io"
}

#resource "konnect_cloud_gateway_transit_gateway" "tfcloudgatewaytransitgateway" {
#  name = "Terraform Transit Gateway"
#
#  cidr_blocks = [
#    "192.168.0.0/24",
#  ]
#
#  transit_gateway_attachment_config = {
#    aws_transit_gateway_attachment_config = {
#      kind               = "aws-transit-gateway-attachment"
#      ram_share_arn      = "arn:aws:ram:eu-west-1:111122223333:resource-share/73da1ab9-b94a-4ba3-8eb4-45917f7f4b12"
#      transit_gateway_id = "arn:aws:ec2:eu-west-1:111122223333:transit-gateway/tgw-0262a0e521EXAMPLE"
#    }
#  }
#
#  network_id = konnect_cloud_gateway_network.tfcloudgatewaynetwork.id
#}