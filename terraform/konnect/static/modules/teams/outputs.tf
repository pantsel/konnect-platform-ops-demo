// Outputs of the teams module

output "teams" {
    value = {
        flight_data_team = konnect_team.flight_data_team
    }
}