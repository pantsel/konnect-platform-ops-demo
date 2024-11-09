// Outputs for the control planes module
output "control_planes" {
  value = {
    demo_cp = konnect_gateway_control_plane.demo_cp
  }
}