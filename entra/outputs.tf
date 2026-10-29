output "user_upns" {
  description = "Sign-in name for each user"
  value       = { for key, user in azuread_user.user : key => user.user_principal_name }
}

output "department_groups" {
  description = "Security group created for each department"
  value       = { for key, group in azuread_group.department : key => group.display_name }
}

output "synced_group_id" {
  description = "Object ID of the dynamic NovaLab Synced Users group"
  value       = azuread_group.synced_users.object_id
}