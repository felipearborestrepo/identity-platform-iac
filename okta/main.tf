locals {
  config       = yamldecode(file("${path.module}/../entra/users.yaml"))
  email_domain = "arbofelipe2003outlook.onmicrosoft.com"
}

resource "okta_group" "department" {
  for_each = toset(local.config.departments)

  name        = "NL-${each.key}"
  description = "NovaLab ${each.key} department (managed by Terraform)"
}

resource "random_password" "okta_user" {
  for_each = local.config.users

  length      = 20
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "okta_user" "user" {
  for_each = local.config.users

  first_name   = split(" ", each.value.display_name)[0]
  last_name    = split(" ", each.value.display_name)[1]
  login        = "${each.key}@${local.email_domain}"
  email        = "${each.key}@${local.email_domain}"
  department   = each.value.department
  title        = each.value.job_title
  organization = local.config.company
  password     = random_password.okta_user[each.key].result
  status       = try(each.value.enabled, true) ? "ACTIVE" : "SUSPENDED"
}

resource "okta_group_rule" "department" {
  for_each = toset(local.config.departments)

  name              = "NL-${each.key}-rule"
  status            = "ACTIVE"
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "user.department==\"${each.key}\""
  group_assignments = [okta_group.department[each.key].id]
}