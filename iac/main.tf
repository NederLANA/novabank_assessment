# ===============================================================
# main.tf - the actual Azure resources, top to bottom.
# Lines starting with "# SAY:" are prompts for YOU during the live demo.
# Lines starting with "# NOT USED:" are options of the module/resource we deliberately skip.
# ===============================================================

locals {
  suffix = "${var.project}-${var.environment}-${var.location_short}" # e.g. novabank-dev-weu  (weu = West Europe)

  # SAY: "Every resource carries the same tags - that is how finance and audit find owners and environments."
  tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
  }
}

# Random text so globally-unique names (the database server) do not collide.
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

# ---------------------------------------------------------------
# 1) RESOURCE GROUP  (a folder in Azure that holds everything for one environment)
# Module: CloudNationHQ/rg/azure  ->  https://registry.terraform.io/modules/CloudNationHQ/rg/azure/latest
# SAY: "I used CloudNation's own resource-group module; dev and prod are separate groups so access and cost are separate."
# ---------------------------------------------------------------
module "rg" {
  source  = "CloudNationHQ/rg/azure"
  version = "~> 2.6"

  groups = {
    main = {
      name     = "rg-${local.suffix}"
      location = var.location
      tags     = local.tags
      # NOT USED: management_lock = { level = "CanNotDelete" }
      #   (a lock protects prod from accidental deletion, but would block 'terraform destroy' in this PoC)
      # NOT USED: use_existing_group = true   (for re-using a group someone else created)
      # NOT USED: managed_by = "..."          (only for groups managed by another service)
    }
  }
}

# ---------------------------------------------------------------
# 2) LOG ANALYTICS  (central logging: the "black box recorder")
# SAY: "Central logs, kept 365 days, satisfy the 12-month audit requirement. Access is controlled with RBAC."
# Module alternative for later: CloudNationHQ/law/azure (I used the plain resource: only 7 lines, easier to explain)
# ---------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg.groups.main.name
  sku                 = "PerGB2018" # pay per GB; small volumes are cheap
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb # cost guard in dev; prod uses -1 so audit logs are never dropped
  tags                = local.tags
}

# ---------------------------------------------------------------
# 3) DATABASE  (managed PostgreSQL: Azure does patching, backups, monitoring)
# SAY: "Managed service = less work and audit evidence for NovaBank. Smallest size, because the PoC holds public catalogue data only."
# Module exists (CloudNationHQ/psql/azure) but it also needs Entra ID (azuread) permissions and identity features -
#   more than this PoC needs, so I used the plain resource. Good next step.
# ---------------------------------------------------------------
resource "random_password" "db" {
  length  = 24
  special = false # avoids characters that break connection strings
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                          = "psql-${local.suffix}-${random_string.suffix.result}"
  resource_group_name           = module.rg.groups.main.name
  location                      = var.location
  version                       = "16"
  sku_name                      = "B_Standard_B1ms" # smallest 'burstable' size, free-tier eligible
  storage_mb                    = 32768
  administrator_login           = var.db_admin_user
  administrator_password        = random_password.db.result
  backup_retention_days         = 7     # point-in-time restore: supports RPO <= 1 hour
  geo_redundant_backup_enabled  = false # NOT USED: true copies backups to the paired region (EU) for disaster recovery
  public_network_access_enabled = true  # PoC COMPROMISE. Next step: private access (VNet / private endpoint)
  tags                          = local.tags

  # NOT USED: high_availability { mode = "ZoneRedundant" }  -> next step for prod to reach the 99.9% target
  # NOT USED: authentication { active_directory_auth_enabled = true }  -> passwordless Entra ID login, next step

  lifecycle {
    ignore_changes = [zone] # Azure picks a zone; this stops Terraform from fighting it
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "novabank"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# SAY (be upfront): "This rule lets Azure services connect. It is a PoC shortcut, listed as a risk; the fix is private networking."
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Send database logs and metrics to the central workspace
resource "azurerm_monitor_diagnostic_setting" "psql" {
  name                       = "diag-psql-to-law"
  target_resource_id         = azurerm_postgresql_flexible_server.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------------
# 4) CONTAINER APP  (runs the API; scales up when many people arrive, down to zero when quiet)
# SAY: "This is the surge answer: when a celebrity drop hits, Azure adds copies of the API automatically."
# Module alternative for later: CloudNationHQ/ca/azure (supports private registry pull + Key Vault secrets)
# ---------------------------------------------------------------
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg.groups.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id # container logs flow here automatically
  tags                       = local.tags
  # NOT USED: infrastructure_subnet_id = ...  (VNet integration = next step for Zero Trust networking)
}

resource "azurerm_container_app" "api" {
  name                         = "ca-${local.suffix}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = module.rg.groups.main.name
  revision_mode                = "Single"
  tags                         = local.tags

  # SAY: "The password is generated by Terraform and stored as a secret - never in code. Next step: Key Vault + passwordless Entra login."
  secret {
    name  = "db-password"
    value = random_password.db.result
  }

  template {
    min_replicas = var.min_replicas # dev 0 (cheap), prod 1 (always warm)
    max_replicas = var.max_replicas

    container {
      name   = "api"
      image  = var.container_image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "DB_HOST"
        value = azurerm_postgresql_flexible_server.main.fqdn
      }
      env {
        name  = "DB_NAME"
        value = azurerm_postgresql_flexible_server_database.app.name
      }
      env {
        name  = "DB_USER"
        value = var.db_admin_user
      }
      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name  = "APP_ENV"
        value = var.environment
      }

      liveness_probe {
        transport = "HTTP"
        port      = 8080
        path      = "/health"
      }
    }

    # SAY: "If more than about 20 requests are in flight per copy, add another copy - up to the maximum."
    http_scale_rule {
      name                = "http-surge"
      concurrent_requests = "20"
    }
  }

  ingress {
    external_enabled = true # the catalogue is meant to be public; everything else stays private
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# ---------------------------------------------------------------
# 5) GOVERNANCE  (guardrails that keep everyone inside the lines)
# SAY: "Same idea as CloudNation's baseline policies: allowed locations first, then required tags. Policy stops mistakes before they happen."
# ---------------------------------------------------------------
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations" # built-in Azure policy
}

data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag on resources" # built-in Azure policy
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "eu-only-locations"
  resource_group_id    = module.rg.groups.main.id # if this errors ("no attribute id"), see iac/README.md
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_environment_tag" {
  name                 = "require-environment-tag"
  resource_group_id    = module.rg.groups.main.id
  policy_definition_id = data.azurerm_policy_definition.require_tag.id
  parameters = jsonencode({
    tagName = { value = "environment" }
  })
}

# Cost alert (optional - turn on with enable_budget = true)
resource "azurerm_consumption_budget_resource_group" "main" {
  count             = var.enable_budget ? 1 : 0
  name              = "budget-${local.suffix}"
  resource_group_id = module.rg.groups.main.id
  amount            = var.budget_amount
  time_grain        = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = [var.budget_email]
  }
}
