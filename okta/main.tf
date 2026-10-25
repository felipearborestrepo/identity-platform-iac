locals {
  config       = yamldecode(file("${path.module}/../entra/users.yaml"))
  email_domain = "arbofelipe2003outlook.onmicrosoft.com"
}

resource "okta_group" "department" {
  for_each = toset(local.config.departments)

  name        = "NL-${each.key}"
  description = "NovaLab ${each.key} department (managed by Terraform)"
}

moved {
  from = okta_group.finance
  to   = okta_group.department["Finance"]
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
  group_assignments = [okta_group.department[each.key].id]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "user.department==\"${each.key}\""
}

resource "okta_app_signon_policy" "it_portal" {
  name        = "NL-IT-Portal-Policy"
  description = "IT only, with MFA (managed by Terraform)"
}

resource "okta_app_signon_policy_rule" "it_mfa" {
  policy_id                   = okta_app_signon_policy.it_portal.id
  name                        = "Allow IT with MFA"
  priority                    = 2
  access                      = "ALLOW"
  factor_mode                 = "2FA"
  groups_included             = [okta_group.department["IT"].id]
  re_authentication_frequency = "PT2H"

  depends_on = [okta_app_signon_policy_rule.deny_blocked]
}

resource "okta_app_bookmark" "it_portal" {
  label                 = "NovaLab IT Portal"
  url                   = "https://example.com"
  authentication_policy = okta_app_signon_policy.it_portal.id
}

resource "okta_app_group_assignment" "it_portal" {
  app_id   = okta_app_bookmark.it_portal.id
  group_id = okta_group.department["IT"].id
}

resource "okta_network_zone" "blocked" {
  name     = "NL-Blocked-Networks"
  type     = "IP"
  usage    = "POLICY"
  status   = "ACTIVE"
  gateways = var.blocked_ip_ranges
}

resource "okta_app_signon_policy_rule" "deny_blocked" {
  policy_id          = okta_app_signon_policy.it_portal.id
  name               = "Deny blocked networks"
  priority           = 1
  access             = "DENY"
  network_connection = "ZONE"
  network_includes   = [okta_network_zone.blocked.id]
}