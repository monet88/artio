# Skill Invocation Rule

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

### Decision flow
1. User message received → scan skill list for any relevance (even 1% match)
2. If a skill might apply → **read its SKILL.md** (skills evolve — never rely on memory)
3. Announce: "Using [skill] for [purpose]"
4. If the skill has a checklist → create todos per item
5. Follow skill instructions exactly
6. If no skill applies → respond normally

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "Let me explore/gather/check first" | Skills tell you HOW to explore. Check skills BEFORE any action. |
| "This is simple / overkill / doesn't count" | If a skill exists for it, use it. Simple things become complex. |
| "I remember this skill" | Skills evolve. Always read the current SKILL.md. |
| "I know what that means" | Knowing the concept ≠ following the skill. Invoke it. |
| "I'll combine skills my own way" | Follow each skill's own instructions. Don't freelance. |
| "The user just wants X done fast" | Instructions say WHAT, not HOW. Skills define the HOW. |

## Skill Priority

When multiple skills could apply, use this order:

1. **Meta-workflow first** (superpowers-workflow) — orchestrates the full cycle
2. **Process skills second** (superpowers-brainstorm, superpowers-debug, debugger, superpowers-tdd, superpowers-review, superpowers-finish, sequential-thinking) — these determine HOW to approach the task
3. **Planning skills third** (superpowers-plan, planner, plan-checker, research, docs-seeker) — these structure the work
4. **Domain skills fourth** (flutter-expert, mobile-design, frontend-design, feature-forge, design-md, enhance-prompt, payment-integration) — these guide implementation
5. **Utility/context skills as needed** (context-fetch, context-compressor, context-health-monitor, token-budget, code-reviewer, empirical-validation, git) — these support execution
6. **Automation skills when applicable** (superpowers-python-automation, superpowers-rest-automation) — for API/scripting tasks

"Build X" → brainstorm first, then domain skills.
"Fix this bug" → superpowers-debug/debugger first, then domain skills.
"Review this" → superpowers-review or code-reviewer.
"Plan this" → superpowers-plan or planner.
"Need docs" → docs-seeker for library/API documentation.

## Skill Types

**Rigid** (TDD, debugging, workflow): Follow exactly. Don't adapt away discipline.
**Flexible** (patterns, design): Adapt principles to context.
The skill itself tells you which.

## Skill Catalog (32 skills)

### Process & Workflow
| Skill | When to use |
|-------|-------------|
| `superpowers-workflow` | Orchestrates brainstorm→plan→implement→review→finish. Use for almost any non-trivial change. |
| `superpowers-brainstorm` | Before non-trivial implementation or design changes. Produces goals/constraints/risks/options/recommendation. |
| `superpowers-debug` | Troubleshooting errors, failing tests, unexpected behavior. Systematic: reproduce→isolate→hypothesize→fix. |
| `superpowers-tdd` | Implementing features, fixing bugs, refactoring. Tests-first discipline (red/green/refactor). |
| `superpowers-review` | Before finalizing changes. Reviews correctness, edge cases, style, security, maintainability. |
| `superpowers-finish` | End of implementation/debugging session. Runs verification, summarizes changes, notes follow-ups. |
| `sequential-thinking` | Complex problems needing step-by-step analysis with revision capability. |
| `debugger` | GSD systematic debugging with persistent state and fresh context advantages. |

### Planning & Research
| Skill | When to use |
|-------|-------------|
| `superpowers-plan` | Before non-trivial changes. Writes small-step plan with exact files and verification commands. |
| `planner` | GSD phase plans with task breakdown, dependency analysis, goal-backward verification. |
| `plan-checker` | Validates plans before execution to catch issues early. |
| `research` | Technical solutions research, architecture analysis, requirements gathering, technology evaluation. |
| `docs-seeker` | Library/framework docs via Context7. API docs, GitHub repo analysis, latest library features. |

### Domain & Implementation
| Skill | When to use |
|-------|-------------|
| `flutter-expert` | Flutter 3+/Dart development: widgets, Riverpod, GoRouter, platform-specific, performance. |
| `mobile-design` | Mobile-first design: touch interaction, performance, platform conventions (iOS/Android). |
| `frontend-design` | Web UI design thinking: components, layouts, colors, typography, aesthetics. |
| `feature-forge` | Feature definition, requirements gathering, user stories, EARS format specs. |
| `design-md` | Analyze Stitch projects and synthesize semantic design systems into DESIGN.md. |
| `enhance-prompt` | Transform vague UI ideas into polished Stitch-optimized prompts. |
| `payment-integration` | Payment integrations: SePay, Polar, Stripe, Paddle, Creem.io. Checkout, webhooks, subscriptions. |

### Utility & Context
| Skill | When to use |
|-------|-------------|
| `context-fetch` | Search-first approach to reduce unnecessary file reads. |
| `context-compressor` | Compress context to maximize token efficiency. |
| `context-health-monitor` | Monitor context complexity, trigger state dumps before quality degrades. |
| `token-budget` | Token budget estimation and tracking to prevent context overflow. |
| `code-reviewer` | PR reviews, code quality audits, security vulnerability identification. |
| `empirical-validation` | Requires proof before marking work complete — no "trust me, it works". |
| `git` | Git operations with conventional commits, auto-split by type/scope, secret scanning. |
| `codebase-mapper` | Analyze existing codebases for structure, patterns, and technical debt. |
| `verifier` | GSD validation of implemented work against spec with empirical evidence. |
| `executor` | GSD plan execution with atomic commits, deviation handling, checkpoints. |

### Automation & Integration
| Skill | When to use |
|-------|-------------|
| `superpowers-python-automation` | Python scripts/services calling external REST APIs: httpx, retries, typing, tests. |
| `superpowers-rest-automation` | REST API integrations: auth, pagination, retries, rate limits, webhooks, data mapping. |
