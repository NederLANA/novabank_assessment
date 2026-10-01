# Migration assessment (7R) and gated roadmap

Note: the 7Rs come from AWS (extending Gartner's earlier 5Rs). Microsoft's Cloud Adoption Framework
uses its own terms (retire, retain, rehost, replatform, refactor, rearchitect, rebuild, replace).
We use the 7R words with a simple mapping: Repurchase ~ Replace, Refactor ~ Rearchitect/Rebuild.
All workloads below are **assumed** (see assumptions.md T2).

## Portfolio view
| # | Workload (assumed) | 7R | Difficulty | In this PoC? |
|---|---|---|---|---|
| 1 | Central logging (local files -> Log Analytics) | Repurchase (managed service) | Easy | Yes |
| 2 | Public gift-card catalogue API (non-personal) | Replatform (containerise unchanged) | Easy | Yes (dev + prod) |
| 3 | PostgreSQL database | Replatform (same engine, managed) | Hard | Empty catalogue copy only |
| 4 | Reporting and batch jobs reading the DB | Retain until mapped | Hard | No |
| 5 | Customer login/identity | Repurchase or Retain | Hard | No |
| 6 | Ledger and payment-scheme connectors | Retain (revisit later) | Very hard | No |
| 7 | Forgotten apps/DBs found in discovery | Retire (or Retain) | Unknown | No |

## Decision questions per workload (use in Discover)
1. Is it still needed? No -> **Retire**.
2. Does a SaaS product cover 80%+? Yes -> **Repurchase**.
3. Must it stay on-prem (regulation, latency, unresolved dependencies)? Yes -> **Retain**.
4. Standard middleware with a managed equivalent? Yes -> **Replatform**.
5. Needs code/architecture change to meet goals? **Refactor**, but after the move, not during it.
6. Default for stable, low-risk workloads: **Rehost**.

## Waves and gates (nothing moves until the previous gate passes)
| Wave | Scope | Gate to pass before the next wave |
|---|---|---|
| 0 Discover | Dependency map, data classification, DPIA, DORA criticality + register entry, exit plan | Business + compliance sign-off on assumptions |
| 1 Foundation | Policy (EU only, tags), logging (365 d), dev with synthetic/public data | Security baseline passes, logs queryable, restore test vs RPO/RTO |
| 2 Prod shell | Prod environment, no customer data | Pen test, access review, residency evidence (regions, backups, logs) |
| 3 Shadow | One-way replication to a read-only DB, shadow traffic | Data reconciliation matches, functional tests, audit evidence pack |
| 4 Canary | Cut over one low-risk function, then others | Rollback rehearsed, sign-off per step |

## Hard workloads: assess before migrating
**PostgreSQL (#3)**: questions: version/extensions, size, who else reads it, acceptable downtime
(weekend window vs near-zero), encryption and key ownership, backup/PITR evidence. Options:
dump/restore (simple, needs downtime) vs online replication/migration service (less downtime,
more setup). Evidence: row-count and checksum reconciliation, restore test, EU-only proof.

**Reporting/batch (#4)**: questions: which jobs, schedules, consumers, data copies, owners.
Risk: hidden readers break silently. Evidence: query logs from the source DB for 30 days.

**Ledger/payments (#6)**: questions: scheme rules, latency, certification, vendor contracts, DORA
criticality, exit plan. Likely stays on-prem; connect privately later (VPN/ExpressRoute).

## Land - expand - run - innovate (partner path, maps to 6D)
Land: foundation + PoC. Expand: gated migration waves. Run: managed operations (monitoring vs 99.9%,
DR tests, FinOps, DORA evidence packs) = Continuous Delivery. Innovate: AI on governed data.
