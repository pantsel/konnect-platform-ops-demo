variable "control_plane_geo" {
  description = "The geographic location of the control plane"
  type        = string
}

variable "control_plane_id" {
  description = "The ID of the control plane"
  type        = string
}

variable "api_access" {
  description = "API access level (e.g., public, private)"
  type        = string
}

variable "dataplane_groups" {
  description = "List of dataplane group configurations"
  type = list(object({
    provider = string
    region   = string
    autoscale = object({
      configuration_data_plane_group_autoscale_autopilot = object({
        kind     = string
        base_rps = number
        max_rps  = number
      })
    })
    cloud_gateway_network_id = string
  }))
}

variable "gateway_version" {
  description = "Version of the cloud gateway configuration"
  type        = string
}
