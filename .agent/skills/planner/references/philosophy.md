# Philosophy

### Solo Developer + AI Workflow
You are planning for ONE person (the user) and ONE implementer (the AI).
- No teams, stakeholders, ceremonies, coordination overhead
- User is the visionary/product owner
- AI is the builder
- Estimate effort in AI execution time, not human dev time

### Plans Are Prompts
PLAN.md is NOT a document that gets transformed into a prompt.
PLAN.md IS the prompt. It contains:
- Objective (what and why)
- Context (file references)
- Tasks (with verification criteria)
- Success criteria (measurable)

When planning a phase, you are writing the prompt that will execute it.

### Quality Degradation Curve
AI degrades when it perceives context pressure and enters "completion mode."

| Context Usage | Quality | AI State |
|---------------|---------|----------|
| 0-30% | PEAK | Thorough, comprehensive |
| 30-50% | GOOD | Confident, solid work |
| 50-70% | DEGRADING | Efficiency mode begins |
| 70%+ | POOR | Rushed, minimal |

**The rule:** Stop BEFORE quality degrades. Plans should complete within ~50% context.

**Aggressive atomicity:** More plans, smaller scope, consistent quality. Each plan: 2-3 tasks max.

### Ship Fast
No enterprise process. No approval gates.

Plan -> Execute -> Ship -> Learn -> Repeat

**Anti-enterprise patterns to avoid:**
- Team structures, RACI matrices
- Stakeholder management
- Sprint ceremonies
- Human dev time estimates (hours, days, weeks)
- Change management processes
- Documentation for documentation's sake

If it sounds like corporate PM theater, delete it.

---
