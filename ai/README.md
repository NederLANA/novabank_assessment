# AI component: IaC review

**Purpose.** Before anything is deployed, Claude/copilot reviews Terraform plan and flags
likely problems (non-EU region, missing tags, unintended public endpoints, weak backups, cost).
**Why this helps the client:** fewer broken or non-compliant deployments,
evidence for audits. It supports engineers; it never applies changes.

## Flow
`terraform plan` -> `terraform show -json` -> `plan_to_context.py` (removes secrets, keeps review fields)
-> AI review using `prompts/iac-review-clear.md` -> **person decides** -> `terraform apply`.

## Safeguards
- No state file, no secrets, no customer data are shared; only resource settings.
- In a client setting this runs inside the client's EU tenant (EU-scoped model deployment).
- Deterministic scanners (fmt, validate, a scanner such as Checkov/Trivy, policy-as-code) run first;
  the AI adds context and explanations, it does not replace them.
- Every AI claim must be traceable to a line in the code or it is rejected.

## Prompt log (CLEAR loop). AI assistant used: Claude (Anthropic).
| # | Prompt (one line) | What the AI gave | Human validation |
|---|---|---|---|
| 1 | "List the likely hidden dependencies of a single-VM portal + on-prem Postgres at a Dutch gift-card issuer." | Dependency candidates (ledger, identity, batch, KYC) | Kept as labelled assumptions (A/T2); cross-checked against the brief; to be confirmed with client |
| 2 | "Which EU/NL rules affect a cloud PoC for an e-money issuer in 2026?" | DORA register + exit plans, GDPR residency, outsourcing | Read the cited DNB/DORA pages; marked "not legal advice" |
| 3 | "Classify these workloads with Azure CAF terms." | Portfolio table | Checked terms against Microsoft CAF sources |
| 4 | "Write minimal Terraform (azurerm ~>4.0), use CloudNationHQ modules only where the schema is verified." | iac/*.tf | Module inputs checked on the registry. **TODO (you): record `terraform validate` and `plan` results** |
| 5 | "Review this sanitised plan against the checklist." (Step 6) | **TODO: run and paste result** | **TODO: mark each finding TRUE/FALSE/PARTLY** |

## Validaiton of AI:
- Used CLEAR prompting framework to ask AI to spar with me to identity gaps of knowledge or test assumptions. Also checked against general knowledge of Gem.
- Used GitHub co-pilot to cross check Claude recommendations.|
- Checked Resource Groups in Azure portal to verify and query build|

