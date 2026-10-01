# IaC reviewer prompt (CLEAR)

Paste this into an AI assistant, then paste the contents of `ai/plan_context.json` where indicated.
Never paste state files, passwords or customer data.

**Concise / Logical / Explicit (the prompt)**

You are a cloud reviewer for a Dutch EU-regulated e-money issuer (assumed: NovaBank, gift cards).
Review the sanitised Terraform plan below against this checklist and answer ONLY in a table:

| Finding | Resource | Severity (high/med/low) | Why it matters (EU residency / Zero Trust / reliability / cost) | Suggested fix | Confidence (high/med/low) |

Checklist:
1. Every resource is in an EU region (westeurope, northeurope, germanywestcentral, swedencentral).
2. Tags `project`, `environment`, `owner` present.
3. Unintended public endpoints (the API ingress is intentionally public; the database is not meant to be).
4. Log retention >= 365 days and diagnostics sent to Log Analytics.
5. Database backups: retention, geo-redundancy, high availability versus a 99.9% availability target.
6. Cost: SKUs larger than needed for a PoC.
7. Anything that looks like a secret stored in plain text.

Rules: only use facts in the plan; if the plan does not show something, put it under "Could not verify".
End with the 3 most important fixes in priority order.

PLAN CONTEXT:
<paste ai/plan_context.json here>

**Adaptive / Reflective (your loop)**
1. Read the answer. Mark each finding: TRUE (confirmed in code) / FALSE (hallucinated) / PARTLY.
2. Reply once with corrections: "Finding 3 is wrong because ...; re-check findings 4 and 5."
3. Keep only findings you can point to in `main.tf`. Log what you accepted and rejected in `ai/README.md`.
