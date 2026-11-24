locals {
  graph_app_id    = "00000003-0000-0000-c000-000000000000"
  graph_user_read = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
}

data "azuread_client_config" "current" {}

resource "azuread_application" "employee_portal" {
  display_name            = "NovaLab Employee Portal"
  owners                  = [data.azuread_client_config.current.object_id]
  sign_in_audience        = "AzureADMyOrg"
  group_membership_claims = ["SecurityGroup"]


  public_client {
    redirect_uris = ["http://localhost"]
  }

  optional_claims {
    id_token {
      name = "email"
    }
  }

  required_resource_access {
    resource_app_id = local.graph_app_id

    resource_access {
      id   = local.graph_user_read
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "employee_portal" {
  client_id                    = azuread_application.employee_portal.client_id
  owners                       = [data.azuread_client_config.current.object_id]
  app_role_assignment_required = true
}