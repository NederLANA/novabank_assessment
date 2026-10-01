# iac/ - Infrastructure as Code (Terraform, Azure)

Files: `versions.tf` (tools), `variables.tf` (knobs), `main.tf` (resources), `outputs.tf` (results),
`envs/dev.tfvars` and `envs/prod.tfvars` (per-environment values).

Use one Terraform workspace per environment so state is separate:
`terraform workspace new dev` / `terraform workspace new prod`. Exact commands: `../demo/README.md`.

## If something breaks
- **"attribute id not found" on `module.rg.groups.main.id`**: replace it with a data source:
  `data "azurerm_resource_group" "main" { name = module.rg.groups.main.name }` and use `data.azurerm_resource_group.main.id`.
- **"location restricted" for PostgreSQL**: set `location = "northeurope"` (or germanywestcentral / swedencentral) in the tfvars.
- **Policy denies a resource**: the resource lacks the `environment` tag or sits outside `allowed_locations`.
- **Budget fails**: keep `enable_budget = false` and create the budget in the portal (Cost Management).
- **Provider not registered**: run the `az provider register` lines from `../demo/README.md`.
