# BUILD GUIDE - 3 hours, step by step (for you, with Claude as sparring partner)

Rhythm for every step: **Spar** (Claude asks, you decide) -> **Build** -> **Document** (Claude drafts) -> **Validate** (you check) -> **Defend** (say it out loud once).
CLEAR in practice: write short, explicit asks; after each answer, adapt (correct it) and reflect (what did I verify?).
Checkpoints: if you stop, note the last checkpoint (CP) you passed and tell Claude "resume at CP-x".

Legend: 🟦 learn | 🟩 say it | 🟨 watch out | 🟥 avoid | 🟪 consultant lens

## Step 0 - Setup (10 min)  [CP-0]
- Sign up: Azure free account (new customer only). Do NOT upgrade to pay-as-you-go.
- Create an empty public GitHub repo, copy this folder into it, open Codespaces.
- Run `demo/README.md` section 0. Check: `az account show` works.
- 🟨 If the Azure signup rejects you or shows no free credit, tell Claude: we switch to dev-only, minimal sizing.

## Step 1 - Frame the problem (20 min)  [CP-1]
Spar: 1) Which 3 pains cost NovaBank most, and what number would prove each? 2) What is the cheapest first step that shows value?
Do: read `docs/assumptions.md`; change anything you disagree with (it is YOUR defense).
🟪 Price the surge: lost cards x margin (see speaking-points.md section 2).
Document: Claude updates assumptions + value hypotheses. Validate: you can explain A1-A5 in 60 seconds.

## Step 2 - Direction (20 min)  [CP-2]
Spar: Why Container Apps and not a VM, App Service or Kubernetes? What would make you change your mind? What is deliberately NOT in scope?
Do: read both SVG diagrams; trace the arrows aloud ("customer -> HTTPS -> API -> TLS -> database; logs -> workspace").
🟩 "Simplest managed services that meet the brief; complexity only when a requirement demands it."

## Step 3 - Foundation in Terraform (35 min)  [CP-3]
Spar: Which guardrails are non-negotiable on day 1? (EU-only policy, tags, central logs.) What is acceptable to skip in a PoC?
Do: read `iac/main.tf` top to bottom with `study/code-companion.md` beside it. Fill `owner` etc. in tfvars.
Run: `terraform init`, `terraform validate`, `terraform plan` (see demo/README.md section 2).
🟨 Errors are normal: copy the exact error to Claude. Do not guess.

## Step 4 - App and database (40 min)  [CP-4]
Spar: What data is safe in dev, and why synthetic/public only? What breaks first under a surge: app, database or connections?
Do: push to `main`, wait for the GitHub Action, make the package public, then `terraform apply` (dev).
Check: `curl $URL/health`, `curl $URL/api/cards` twice (database, then cache).

## Step 5 - Validate (20 min)  [CP-5]
Spar: What evidence would convince an auditor? What would you show a CFO?
Do: demo/README.md section 3 (logs query, policy state, region list, `ab` surge test, replica list). Paste outputs into `docs/architecture-summary.md`.

## Step 6 - AI reviewer (20 min)  [CP-6]
Spar: What decision does the AI help a human make? How do you know it is wrong when it is?
Do: create `plan.json` -> `plan_to_context.py` -> run the CLEAR prompt -> mark every finding TRUE/FALSE/PARTLY in `ai/README.md`.

## Step 7 - Story and rehearsal (15 min now, 60 min Friday)  [CP-7]
Do: read `study/speaking-points.md`; record yourself giving the 3-minute pitch. Friday: mock interview with Claude, then prod deploy only if time allows (otherwise show prod via `terraform plan`).
Cleanup after the meeting: `terraform destroy` for dev and prod.
