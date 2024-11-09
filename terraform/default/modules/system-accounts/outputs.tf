// Outputs of the system-accounts module

output "system_account_access_tokens" {
  value = [
    konnect_system_account_access_token.sa_demo_cp_admin_token
  ]
  sensitive = true
}

