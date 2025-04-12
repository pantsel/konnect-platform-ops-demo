// Outputs for the control planes module
output "control_planes" {
  value = {
    flight_data_cp = konnect_gateway_control_plane.flight_data_cp
    flight_data_cp_group = konnect_gateway_control_plane.flight_data_cp_group
    platform_cp = konnect_gateway_control_plane.platform_cp
  }
}