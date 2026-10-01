# Code Companion - what each part does (for you; not part of the submission)

Legend: 🟦 learn | 🟩 say it | 🟨 watch out | 🟪 consultant lens

## Terraform in 6 sentences
🟦 Terraform reads `.tf` files describing what you want in Azure. `init` downloads plugins (providers) and modules. `plan` shows what it WOULD change. `apply` makes the change. The **state** file remembers what exists. A **module** is a reusable package of resources; a **variable** is a knob; a **workspace** keeps separate state per environment (dev, prod).
🟨 `plan` is safe; `apply` and `destroy` change real things. Always read the plan.

## How the pieces connect (your weak spot, so read twice)
| From | To | How | Protected by | Logged where |
|---|---|---|---|---|
| Customer | Container App | HTTPS via public ingress | TLS | console logs -> Log Analytics |
| Container App | PostgreSQL | TCP 5432 over TLS | password (secret) + firewall rule | DB logs -> Log Analytics (diagnostic setting) |
| Container App environment | Log Analytics | built-in logging link | workspace RBAC | n/a |
| GitHub Actions | ghcr.io | push with GitHub token | repo permissions | Actions logs |
| Azure | ghcr.io | pulls public image | none needed (image has no secrets) | revision logs |
| Policy | Resource group | assignment evaluates every resource | Azure RBAC | compliance state |

## Block by block
**versions.tf** 🟦 Pins Terraform/plugin versions. 🟩 "Repeatable deployments." 🟨 Azure provider v4 needs the subscription id.

**variables.tf** 🟦 The knobs. `environment` is validated to dev/prod. `allowed_locations` feeds the policy. `daily_quota_gb` caps log cost in dev. 🟪 Choosing cheap values for dev and warm/bigger values for prod is a cost decision you can defend.

**locals / tags** 🟦 `locals` are computed names. Tags label every resource (project, environment, owner). 🟪 Tags are how finance finds cost owners and auditors find accountability.

**module "rg"** 🟦 CloudNationHQ's resource-group module takes a `groups` map; each entry becomes a resource group. Commented-out options: management lock (blocks accidental deletion, but also `destroy`), reuse existing group, `managed_by`. 🟩 "I used their module for the part where I verified the schema, plain resources elsewhere." 🟨 Modules are broad on purpose; read the inputs on the registry page before using them.
Where to find modules: https://registry.terraform.io/namespaces/CloudNationHQ (rg, law, ca, acr, psql, vnet...) and github.com/CloudNationHQ.

**Log Analytics workspace** 🟦 Central log store you query with KQL. `retention_in_days = 365` meets the 12-month rule. 🟨 A daily cap can drop logs; fine for dev, not for prod (prod uses -1).

**PostgreSQL Flexible Server** 🟦 Managed database. `B_Standard_B1ms` = smallest burstable size. `backup_retention_days = 7` gives point-in-time restore (supports RPO <= 1 h). `public_network_access_enabled = true` is the PoC shortcut. 🟨 Commented-out HA and Entra login are your "next steps". 🟪 No HA means roughly 99.9% for the database alone and lower combined: say so.

**Firewall rule 0.0.0.0** 🟨 Means "allow Azure services", not "the whole internet". Still weak; private networking replaces it.

**Diagnostic setting** 🟦 Connects the database's logs and metrics to the workspace. 🟩 "Everything reports to one place."

**Container App environment** 🟦 The shared hosting space; sends container logs to the workspace automatically.

**Container App** 🟦 Runs the image. `min_replicas` 0 (dev) saves money; 1 (prod) avoids cold starts. `http_scale_rule` adds copies when concurrent requests exceed 20 per copy. `secret` holds the DB password; the container reads it as an environment variable. `ingress external_enabled` makes the catalogue public. 🟩 "This is the answer to the celebrity drop." 🟨 The image must be public or the app will not start.

**Policy assignments** 🟦 Built-in policies, looked up by name: "Allowed locations" and "Require a tag on resources". They deny non-compliant deployments. 🟩 "Guardrails, not gates." 🟨 If a deployment is denied, read the policy message; it names the missing tag or region.

**Budget** 🟦 Emails you at 80% of the monthly amount. Off by default (`enable_budget`), because some trial subscriptions do not support it.

**outputs.tf** 🟦 Prints the URL and names after apply.

## The app (app/main.py) in 5 lines
`/health` says "I'm alive". `/api/cards` reads the catalogue from PostgreSQL and caches it for 30 seconds in memory so a surge does not hit the database 600 times a second. Every request writes one JSON log line with a correlation id. Table creation on first call is a PoC shortcut. 🟨 Database connections are limited on a small server; "connection pooling" is a next step.

## Questions to ask yourself while reading
What would break if this setting were different? Which line would an auditor ask about? Which line costs money?
