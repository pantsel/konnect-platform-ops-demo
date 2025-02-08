// Outputs for the control planes module
output "control_planes" {
  value = {
    demo_cp = konnect_gateway_control_plane.demo_cp
    global_cp = konnect_gateway_control_plane.global_cp
    demo_cp_group = konnect_gateway_control_plane.demo_cp_group
  }
}