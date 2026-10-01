# ---------------------------------------------------------------
# versions.tf  -  WHICH tools and plugins this code needs
# SAY: "I pin versions so the deployment is repeatable - same code, same result."
# ---------------------------------------------------------------
terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # CloudNation's rg module also targets azurerm ~> 4.0
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # NOT USED in the PoC: remote state (Azure Storage). Local state is simpler.
  # SAY: "Next step: remote, locked state per environment, so a team can work safely."
  # backend "azurerm" { ... }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id # azurerm v4 needs this explicitly
}
