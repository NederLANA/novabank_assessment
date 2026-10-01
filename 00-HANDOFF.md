# 00 - HANDOFF (read this first tomorrow)

Project: NovaBank Cloud & AI assessment for Cloudnation (Azure + Terraform, 3-hour build).
Meeting: Friday 14:00 (Utrecht). Leave by 13:00. Friday morning = review + mock interview.

## Status (updated as files are written)

| Part | What | Status |
|---|---|---|
| A | Handoff tracker (this file) | done |
| B | docs: assumptions, migration assessment (7R + gates), timelog | done |
| C | docs: diagrams (current + target SVG), architecture summary | done |
| D | iac: Terraform (dev + prod), tfvars, README | done |
| E | app: API + Dockerfile + GitHub Action | done |
| F | ai: IaC reviewer (context script + CLEAR prompt + evidence log) | done |
| G | demo runbook | done |
| H | study: BUILD-GUIDE (step by step with sparring questions) | done |
| I | study: speaking points + code companion + AI/CLEAR notes | done |

## How to resume
Tell Claude: "Continue from part X in 00-HANDOFF.md". Claude should re-read this file and the
files already written, finish the pending parts in order, then update this table.

## Colour legend used in study notes
- BLUE  = concept to learn
- GREEN = say this out loud
- YELLOW = watch out / gotcha
- RED   = do not say / avoid
- PURPLE = consultant lens (business value, >EUR 50k problems)

## Things only YOU can do (Claude cannot)
1. Sign up for the Azure free account (card + phone). Do NOT upgrade to pay-as-you-go.
2. Create your own GitHub repo (empty, public) and open it in Codespaces.
3. Run every command in demo/README.md and paste real outputs into docs/architecture-summary.md.
4. Fill the "human validation" column in ai/README.md with what you actually checked.

## Notes from the build session
- Terraform and app code were NOT executed (no Azure access in this session): only the app syntax and the plan-summary script were tested.
  Expect small fixes when you first run `terraform validate/plan`. Paste any error to Claude.
- Modules: only CloudNationHQ/rg is used (schema verified). law/ca/acr/psql exist but were left as plain resources or next steps.
- Still open for tomorrow: answer the outer-layer questions in the chat (your proof story, 3 candidate pains with data, one-sentence impression),
  then run Steps 0-7 in study/BUILD-GUIDE.md. Optional: a colour PDF/HTML version of the study notes.
