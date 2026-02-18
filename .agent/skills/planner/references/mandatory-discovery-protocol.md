# Mandatory Discovery Protocol

Discovery is MANDATORY unless you can prove current context exists.

### Level 0 — Skip
*Pure internal work, existing patterns only*
- ALL work follows established codebase patterns (grep confirms)
- No new external dependencies
- Pure internal refactoring or feature extension
- Examples: Add delete button, add field to model, create CRUD endpoint

### Level 1 — Quick Verification (2-5 min)
- Single known library, confirming syntax/version
- Low-risk decision (easily changed later)
- Action: Quick docs check, no RESEARCH.md needed

### Level 2 — Standard Research (15-30 min)
- Choosing between 2-3 options
- New external integration (API, service)
- Medium-risk decision
- Action: Route to `/research-phase`, produces RESEARCH.md

### Level 3 — Deep Dive (1+ hour)
- Architectural decision with long-term impact
- Novel problem without clear patterns
- High-risk, hard to change later
- Action: Full research with RESEARCH.md

**Depth indicators:**
- Level 2+: New library not in package.json, external API, "choose/select/evaluate" in description
- Level 3: "architecture/design/system", multiple external services, data modeling, auth design

For niche domains (3D, games, audio, shaders, ML), suggest `/research-phase` before `/plan`.

---
