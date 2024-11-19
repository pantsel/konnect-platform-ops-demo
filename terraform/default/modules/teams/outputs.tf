// Outputs of the teams module

output "teams" {
    value = {
        demo_cp_team_readonly = konnect_team.demo_cp_team_readonly
    }
}