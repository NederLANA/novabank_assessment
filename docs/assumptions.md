# Assumptions

The brief leaves NovaBank's applications, dependencies and size open. Every assumption below is
deliberate, labelled, and open for discussion with the client. Status: **confirm** = must be
validated with NovaBank in the Discover phase.

## Business profile
| ID | Assumption | Why | Status |
|---|---|---|---|
| A1 | NovaBank is a small, new, **NL-only** digital issuer of prepaid **gift cards** (EMI-style: e-money, not deposits or lending). | Makes scope and data classes simple; fits "regulated, EU residency". The brief says "digital bank", so the licence type must be confirmed. | confirm |
| A2 | Gift-card demand is seasonal (Christmas, back-to-school) and spiky (celebrity-endorsed limited cards for one city/concert). | Explains why a single VM breaks; drives autoscaling. | confirm |
| A3 | Sizing (illustrative only): ~18M people in NL, ~4 gift cards per person per year, NovaBank share 1% => about 0.7M cards/year. Peak season about 40% of volume in Nov-Dec. | Average load is small; the **spike** is the problem. | confirm |
| A4 | A limited drop could attract about 50,000 buyers within 10 minutes (about 80 sign-ups/s, roughly 600+ requests/s). | Used to justify autoscale and a catalogue cache. | confirm |
| A5 | Net margin per card about EUR 3 (fees + interchange + expected breakage). Card face value is customer money that must be safeguarded, **not** revenue. | Needed to price the surge problem. | confirm |

## Technical and landscape
| ID | Assumption | Status |
|---|---|---|
| T1 | Today: one web API on one VM, PostgreSQL on-prem, local log files, one environment. (From the brief.) | given |
| T2 | Likely hidden dependencies: core ledger/payment-scheme connectors, identity/login, reporting and batch jobs reading the DB, KYC/AML screening, notification services. Not documented in the brief. | confirm |
| T3 | Forgotten apps/databases (possibly replicated across regions) exist. Discovery must inventory them. | confirm |
| T4 | The PoC exposes only **non-personal** data: a public gift-card catalogue. No customer data enters the PoC. | design choice |
| T5 | Azure, Terraform, one subscription, region West Europe (fallback: another EU region if quota/restrictions apply). | design choice |
| T6 | Dev and prod are separate resource groups in one sandbox subscription (production would use separate subscriptions). | PoC compromise |
| T7 | PoC budget below USD 15, using the Azure free account; prod is deployed briefly, validated, then destroyed. | constraint |

## Compliance (not legal advice; verify with NovaBank compliance)
| ID | Assumption |
|---|---|
| C1 | DORA applies to EU financial entities including payment/e-money institutions: ICT risk, incident reporting, resilience testing, third-party register and exit plans. |
| C2 | GDPR applies: EU region alone is necessary but not sufficient; logs, backups, telemetry and support access must also be reviewed for EU residency. |
| C3 | Anti-money-laundering rules (Wwft) and safeguarding of customer funds apply to the real system, not to the catalogue PoC. |
| C4 | Logs retained centrally 12+ months with restricted access (from the brief). |

## Non-functional targets (from the brief)
Availability >= 99.9%, RPO (max data loss) <= 1 h, RTO (max down time) <= 4 h. Note: the PoC prod database has no high availability,
so the **combined** SLA is likely below 99.9%. Zone-redundant HA is the recommended next step
(verify current Azure SLA figures before quoting numbers).

## If NovaBank were a full, worldwide bank headquartered in NL
Would change: multiple supervisors (ECB/DNB plus local regulators), data-localisation laws in some
countries, cross-border transfers, sanctions and AML at scale, multi-region active-active designs,
follow-the-sun operations, concentration-risk and exit planning for the cloud provider, stricter
resilience testing, SWIFT/payments connectivity, and a formal landing zone with management groups.
The migration order stays the same (low-risk first), but each step needs far more evidence.

## Open questions for NovaBank (to price the surge problem)
1. Which past events caused failures, and what do your logs show (if any exist)? Central logging.
2. During an event: peak requests per second, share of requests that failed, minutes of degraded service? Shape of the event. 
3. Funnel: visitors -> started sign-up -> completed purchase. Where do people drop off between landing page and card bought. 
4. Net margin per card, and how many cards does a customer buy per year (repeat rate)?
5. Marketing or celebrity spend tied to each drop?
Pricing logic: lost sales now = failed sign-ups x margin; lost future value = lost customers x expected repeat purchases; plus wasted marketing.
