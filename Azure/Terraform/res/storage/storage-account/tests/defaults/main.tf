# Minimum viable deployment: secure defaults only, no private endpoint.
module "test" {
  source = "../../"

  name              = "stdefaults0001"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
}
