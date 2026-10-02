# Speaking points

Legend: 🟦 learn | 🟩 say it | 🟨 watch out | 🟥 avoid | 🟪 consultant lens
[YOUR STORY] = fill in a real example from your own experience. Do not invent one.

## 0. Opener (30 seconds)
🟩 "I treated this as two projects: the outer one is how a cloud partner helps a client grow safely; the inner one is a small, safe first step. My thesis: **get the foundation right, prove it works, then add AI where it pays.**"

## 1. NovaBank, as I assumed it
🟩 "The brief doesn't say what NovaBank does, so I made explicit assumptions: a small Dutch digital issuer of prepaid gift cards, seasonal peaks, celebrity-driven drops. Every assumption is in one document, labelled, open for you to challenge."
🟦 An e-money institution (EMI) holds customer money in safeguarded accounts; card face value is **not** revenue. Revenue is fees, interchange and breakage.
🟨 The brief says "digital bank". Say: "I'd confirm the licence type first; it changes the rules, not the approach."

## 2. The >EUR 50k problems (brief)
🟪 Method: follow the flow, find where it waits/fails/repeats, price it (frequency x duration x cost per unit), rank by value and ease.
🟩 "The average load is small; the **spike** is the problem. About 50,000 people in 10 minutes is roughly 80 sign-ups a second. If the old VM serves only a fifth, 40,000 sales are lost. At about EUR 3 net per card that is EUR 120k in one event, before the celebrity fee is wasted. These are my numbers; the client's would replace them."
🟪 Extended: other leaks to ask about: forgotten apps/databases (cost + compliance), slow audits (staff hours), incidents found late (no central logs), testing in production (change failures).
🟨 Never present sizing as fact. Say "illustrative, to be confirmed".

## 3. Why this design
🟩 "Managed services unless the use case is too small to justify them. Here Container Apps handles the surge with autoscaling and costs almost nothing when idle. PostgreSQL is managed so NovaBank doesn't patch or back it up. Policy enforces EU locations and tags. Logs are central for 365 days."
🟦 Well-Architected pillars: reliability, security, cost, operational excellence, performance. Zero Trust: verify explicitly, least privilege, assume breach.
🟨 Be upfront about PoC compromises: public DB endpoint with password, no private network or WAF, no HA on prod. "Here is the fix for each."

## 4. Migration: easy first, gates always
🟩 "I only migrate what is safe: central logging and a public, non-personal catalogue API. Database, reporting and the ledger/payments stay until we have evidence. Every wave has a gate: functional checks, security and regulatory evidence, and a rehearsed rollback."
🟦 7R: retire, retain, rehost, relocate, repurchase, replatform, refactor. (Microsoft's CAF has its own list; the words map closely.)

## 5. Business-model insight
🟩 "Customers are drawn in by the cutting-edge story - agents, AI. What they actually buy first is the traditional foundation: landing zone, security, logging, migration, then managed operations. The flashy story opens the door; the basics earn the relationship."
🟪 So: pitch AI as the destination, sell the foundation as the first sprint.

## 6. Both clouds, both sides of the table
🟩 "I know AWS and Azure. Cloudnation's Agent Lake pattern - governed foundation, sprints, managed operations - is on AWS; the Azure building blocks are Foundry for agents, Entra for identity, Policy, Log Analytics. I can map between them."
🟩 "I've seen the consumer side and the provider side of cloud partnerships." [YOUR STORY: what you did to keep a partner relationship strong]
🟦 Partner status generally rests on: certified people, proven customer references/outcomes, revenue/consumption, and technical validation. Each person contributes: certifications, delivery quality, case studies. [YOUR STORY]
🟨 I did not verify whether Cloudnation has an Azure equivalent of Agent Lake - ask: "Do you offer an Azure counterpart, or is that a gap clients ask about?"

## 7. Baseline policies and CCoE
🟩 "Cloudnation applies a baseline of policies (e.g. allowed locations); at Accenture we used a baseline for client environments too, and I helped enforce it as part of a CCoE." [YOUR STORY: one policy you enforced]
🟩 "In this PoC: allowed EU regions, required tags, central logging. That's the same idea at small scale."

## 8. Using AI, honestly
🟩 "AI drafted the Terraform; I verified with validate, plan and the module docs. A second AI step reviews a sanitised plan for risks; I mark each finding true, false or partly. The human decides."
🟥 Don't say "AI wrote it". Say what you checked and what you rejected.

## 9. Growing the relationship with NovaBank
🟩 Discovery questions: What does an hour of downtime cost? How long from idea to production? How much time does an audit or incident take? Which deadline worries you (DORA)? Where would AI help, and is the data ready?
🟩 Path: land (foundation) -> expand (gated waves) -> run (managed ops: monitoring, DR tests, FinOps, DORA evidence) -> innovate (AI on governed data).

## 10. If NovaBank were a global bank based in NL
🟩 "Same order, more evidence: multiple supervisors, data-localisation laws, cross-border transfers, sanctions at scale, multi-region active-active, follow-the-sun operations, concentration risk and exit plans for the cloud provider. That is where managed services and a long relationship matter most."

## 11. Likely tough questions
1. *Why not just lift-and-shift the VM?* Possible and sometimes right (rehost); but the surge problem needs elasticity.
2. *Is a public database endpoint OK?* No for production; it's a documented PoC shortcut; fix: private access + Entra login.
3. *Does the EU region guarantee residency?* No: check backups, logs, support access, and AI model routing.
4. *How do you reach 99.9%?* Zone-redundant HA on the database; combined SLAs are the product of the parts (check current Azure SLAs).
5. *What if the AI is wrong?* It only advises; scanners and humans gate apply.
6. *What would you do next with more time?* Private networking + WAF, Key Vault, HA, restore test, CI pipeline, DORA register.
7. *What don't you know?* NovaBank's real dependencies. That's why Discover is wave 0.
