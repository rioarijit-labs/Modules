# Linux P1v3 plan with one instance.
module "test" {
  source = "../../"

  name              = "asp-defaults"
  location          = "westeurope"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"
}
