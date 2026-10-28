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


