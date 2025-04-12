locals {
  consumers = [
    {
      username = "anonymous"
    }
  ]
  tags = [
    "global_entities",
    "platform"
  ]
}


resource "konnect_gateway_consumer" "global_cp_consumer" {
  for_each         = { for consumer in local.consumers : consumer.username => consumer }
  control_plane_id = konnect_gateway_control_plane.global_cp.id
  tags = local.tags
  username = each.value.username
}

resource "konnect_gateway_plugin_request_termination" "global_cp_plugin_request_termination" {
  config = {
    content_type = "application/json"
    body         = "{\"message\":\"You are not allowed to access this service\"}"
    status_code  = 403
  }
  consumer = {
    id = konnect_gateway_consumer.global_cp_consumer["anonymous"].id
  }
  control_plane_id = konnect_gateway_control_plane.global_cp.id
  enabled          = true
  tags = local.tags
}
