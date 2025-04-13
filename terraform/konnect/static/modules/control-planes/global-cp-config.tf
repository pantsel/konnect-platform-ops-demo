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
  trace_id_lua = <<EOT
local h = kong.request.get_header("traceparent")
if not h then
  return ""
end
return h:match("%-([a-f0-9]+)%-[a-f0-9]+%-")
EOT

  span_id_lua = <<EOT
local h = kong.request.get_header("traceparent")
if not h then
  return ""
end
return h:match("%-[a-f0-9]+%-([a-f0-9]+)%-")
EOT
  opentelemetry_config = merge(
    {
      traces_endpoint = (
        var.observability_stack == "datadog" ? "http://datadog-agent.kong-observability.svc.cluster.local:4318/v1/traces" :
        var.observability_stack == "grafana" ? "http://tempo.kong-observability.svc.cluster.local:4318/v1/traces" :
        "http://localhost:4318/v1/traces"
      )

      resource_attributes = {
        namespace      = jsonencode("kong")
        "service.name" = jsonencode("kong-dp")
      }
    },
    var.observability_stack == "grafana" ? {} : {
      logs_endpoint = (
        var.observability_stack == "datadog"
        ? "http://datadog-agent.kong-observability.svc.cluster.local:4318/v1/logs"
        : "http://localhost:4318/v1/logs"
      )
    }
  )
}


resource "konnect_gateway_vault" "gatewayvault" {
  config = jsonencode({
    protocol = regex("^([^:]+)://", var.vault_address)[0]
    host = var.host_address
    mount = "secret"
    kv = "v2"
    token = var.vault_token
    auth_method = "token"
    port = tonumber(regex("^https?://[^:]+:(\\d+)", var.vault_address)[0])
    ttl = 60
  })
  name             = "hcv"
  prefix           = "hcv-vault"
  control_plane_id = konnect_gateway_control_plane.platform_cp.id

  tags = local.tags
}


resource "konnect_gateway_consumer" "global_cp_consumer" {
  for_each         = { for consumer in local.consumers : consumer.username => consumer }
  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  tags             = local.tags
  username         = each.value.username
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
  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  enabled          = true
  tags             = local.tags
}

resource "konnect_gateway_plugin_prometheus" "global_cp_plugin_prometheus" {
  config = {
    status_code_metrics  = true
    latency_metrics      = true
    bandwidth_metrics    = true
    per_consumer_metrics = true
  }

  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  enabled          = true
  tags             = local.tags
}

resource "konnect_gateway_plugin_rate_limiting_advanced" "global_cp_plugin_rate_limiting_advanced" {
  config = {
    window_size = [60]
    limit       = [3000]
  }

  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  enabled          = true
  tags             = local.tags
}

resource "konnect_gateway_plugin_file_log" "global_cp_plugin_file_log" {
  count = var.observability_stack == "datadog" ? 1 : 0

  config = {
    path = "/dev/stdout"
  }

  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  enabled          = true
  tags             = local.tags
}

resource "konnect_gateway_plugin_http_log" "global_cp_plugin_http_log" {
  count = var.observability_stack == "grafana" ? 1 : 0

  config = {
    custom_fields_by_lua = {
      trace_id = jsonencode(local.trace_id_lua)
      span_id  = jsonencode(local.span_id_lua)
    }

    http_endpoint = "http://fluent-bit.kong-observability.svc.cluster.local:8080"
  }

  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  enabled          = true
  tags             = local.tags
}

resource "konnect_gateway_plugin_tcp_log" "global_cp_plugin_tcp_log" {
  count = var.observability_stack == "dynatrace" ? 1 : 0

  config = {
    custom_fields_by_lua = {
      trace_id = jsonencode(local.trace_id_lua)
    }

    host = "localhost"
    port = "54525"
  }

  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  enabled          = true
  tags             = local.tags
}

resource "konnect_gateway_plugin_opentelemetry" "global_cp_plugin_opentelemetry" {
  config           = local.opentelemetry_config
  control_plane_id = konnect_gateway_control_plane.platform_cp.id
  enabled          = true
  tags             = local.tags
}
