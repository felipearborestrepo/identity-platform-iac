data "azuread_domains" "tenant" {
  only_initial = true
}

locals {
  domain = data.azuread_domains.tenant.domains[0].domain_name
  config = yamldecode(file("${path.module}/users.yaml"))
  users  = local.config.users
}

resource "random_password" "user" {
  for_each = local.users

  length  = 20
  special = true
}

resource "azuread_user" "user" {
  for_each = local.users

  user_principal_name   = "${each.key}@${local.domain}"
  display_name          = each.value.display_name
  mail_nickname         = each.key
  department            = each.value.department
  job_title             = each.value.job_title
  company_name          = local.config.company
  password              = random_password.user[each.key].result
  force_password_change = true
  account_enabled       = try(each.value.enabled, true)
}

resource "azuread_group" "department" {
  for_each = toset(local.config.departments)

  display_name     = "SG-${each.key}"
  description      = "${each.key} department (managed by Terraform)"
  security_enabled = true
}

resource "azuread_group_member" "department" {
  for_each = local.users

  group_object_id  = azuread_group.department[each.value.department].object_id
  member_object_id = azuread_user.user[each.key].object_id
}

resource "azuread_group" "synced_users" {
  display_name     = "${local.config.company} Synced Users"
  description      = "All enabled ${local.config.company} users (dynamic)"
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "(user.companyName -eq \"${local.config.company}\") and (user.accountEnabled -eq true)"
  }
}

