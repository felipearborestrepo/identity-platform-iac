output "user_upns" {
  value = { for key, u in azuread_user.user : key => u.user_principal_name }
}

output "synced_group_id" {
  value = azuread_group.synced_users.object_id
}