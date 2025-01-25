locals {
  tags = [
    "global_entities",
    "platform"
  ]
}

resource "konnect_gateway_consumer" "anonymous" {
  for_each = {
    for cp in konnect_gateway_control_plane.cps : cp.id => cp
  }
  control_plane_id = each.value.id
  tags             = local.tags
  username         = "anonymous"
}

resource "konnect_gateway_plugin_request_termination" "global_cp_plugin_request_termination" {
  
  for_each = {
    for cp in konnect_gateway_control_plane.cps : cp.id => cp
  }
  
  config = {
    content_type = "application/json"
    body         = "{\"message\":\"You are not allowed to access this resource\"}"
    status_code  = 403
  }

  consumer = {
    id = konnect_gateway_consumer.anonymous[each.value.id].id
  }
  
  control_plane_id = each.value.id
  enabled          = true
  tags = local.tags
}
