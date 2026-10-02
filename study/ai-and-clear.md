# AI in engineering today, and how CLEAR fits

🟦 **Industry standard (2026), in one line:** AI drafts, machines check, humans approve. Treat AI output like work from a capable junior engineer.
Typical pipeline for AI-written infrastructure: `fmt` -> `validate` -> linter -> security scanner (Checkov, Trivy) -> policy-as-code (OPA/Azure Policy) -> a plan attached to the pull request -> human review -> apply. Apply stays behind human or pipeline approval.

🟦 **Why the care:** surveys say a large share of new code is now AI-written or AI-assisted (Sonar's 2026 survey: about 42%), and studies find AI often omits security-relevant settings (encryption, logging) in Terraform because the code "looks complete". Sources to name: Sonar blog "AI is writing more of your Terraform", Spacelift "Using Terraform with AI", DevOps.com on governing AI-generated infrastructure.

🟩 **Answer to your question:** Both uses are legitimate. (1) AI to *generate* drafts = fast, accepted, but you must verify with validate/plan. (2) AI to *review* a plan before deploy = the better story for the client, because it reduces breakage and gives audit evidence. In the demo, say: "I used AI to draft, then verified with Terraform and a reviewer step; the human decides."

🟥 Do not say "the AI did it". Say what you checked.

## CLEAR (Concise, Logical, Explicit, Adaptive, Reflective) as a loop
1. Write the ask: short, ordered, explicit about format and constraints (C, L, E).
2. Read the answer critically; correct it in one reply (A).
3. Record what you verified and what you rejected (R). That record is your "AI evidence".
🟪 Your edge: you supply the business context (what hurts, what it costs); AI supplies speed. Say that.
