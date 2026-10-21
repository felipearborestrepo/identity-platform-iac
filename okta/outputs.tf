output "groups" {
    value = { for dept, g in okta_group.department : dept => g.name}
}

output "group_rules" {
    value = {for dept, r in okta_group_rule.department : dept => r.expression_value}
}