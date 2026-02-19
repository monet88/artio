# Model Selection Playbook for Artio

> Guidance for choosing AI models by development phase and task type in the Artio Flutter project.
>
> **No specific model is required.** These are recommendations based on task complexity and context needs.

---

## Selection by Phase

### Planning & Architecture

**Recommended capabilities:**
- Extended reasoning / thinking mode
- Large context window (analyze multiple files)
- Strong at structured output (specs, plans)

**Why:** Planning requires understanding full system context and making architectural decisions.

**Examples:** Models with "thinking" or "reasoning" modes, larger context variants.

---

### Code Implementation

**Recommended capabilities:**
- Fast iteration speed
- Good at code completion
- Tool/function calling (for verification commands)

**Why:** Implementation involves many small changes with frequent verification cycles.

**Examples:** Speed-tier models, code-specialized variants.

---

### Refactoring

**Recommended capabilities:**
- Large context window (see before/after)
- Pattern recognition
- Consistent style application

**Why:** Refactoring requires maintaining consistency across large code changes.

**Examples:** Standard or long-context variants.

---

### Debugging

**Recommended capabilities:**
- Extended reasoning (hypothesis generation)
- Good at reading stack traces
- Context for error patterns

**Why:** Debugging requires hypothesis testing and pattern matching.

**Examples:** Reasoning-focused models.

---

### Code Review

**Recommended capabilities:**
- Large context (review full PR diff)
- Security pattern knowledge
- Style consistency checking

**Why:** Review requires seeing both code and context together.

**Examples:** Long-context variants.

---

## Capability Tiers

| Tier | Characteristics | Best For |
|------|-----------------|----------|
| **Fast** | Quick responses, lower cost | Implementation, iteration |
| **Standard** | Balanced speed/quality | Most tasks |
| **Reasoning** | Extended thinking, slower | Planning, debugging, architecture |
| **Long-context** | >100k tokens | Review, refactoring |

---

## Anti-Patterns

❌ **Using reasoning models for simple edits** — Overkill, slow, expensive

❌ **Using fast models for architecture** — Insufficient depth for complex decisions

❌ **Ignoring context limits** — Leads to quality degradation

❌ **Forcing a specific model** — Breaks model-agnosticism

---

## Model Switching Mid-Session

**When to switch:**
- Context approaching token limit (>50%)
- Task type changes significantly (architecture → implementation)
- Current model struggling with task complexity
- Performance degradation detected (shorter responses, skipped details)

**How to switch:**
1. Commit current work
2. Create summary of findings in task comments
3. Start fresh session with appropriate model
4. Load development-roadmap.md for context

---

## Task-Specific Recommendations

### Architecture & Planning
- **Use:** Extended reasoning, large context (analyze multiple files)
- **Why:** Decisions impact entire codebase (Feature-First clean architecture)
- **Example:** Planning Phase 6 (Credits & Subscription system)

### Bug Fixes & Debugging
- **Use:** Standard or reasoning model with search-first approach
- **Why:** Need to trace through Riverpod providers, repositories, and UI layers
- **Example:** Fixing realtime update timing in gallery feature

### UI/Widget Implementation
- **Use:** Fast model with frequent iteration
- **Why:** Many small changes, visual feedback-driven development
- **Example:** Building CreateScreen input fields

### Test Writing
- **Use:** Standard model with fixture patterns
- **Why:** Tests follow predictable patterns (mocks, setup, assertions)
- **Example:** Writing GenerationRepositoryTest

### Code Review & Refactoring
- **Use:** Large context window (see before/after diffs)
- **Why:** Maintain consistency across 7 features and 85+ source files
- **Example:** Applying token optimization patterns across codebase

---

## Artio-Specific Context

**Key consideration:** Artio uses Riverpod 2.x with code generation, so any AI model must:
1. Understand `@riverpod` annotations and `AsyncValue` patterns
2. Be aware of code generation artifacts (build_runner, .freezed.dart, .g.dart)
3. Follow 3-layer clean architecture (domain/data/presentation)
4. Respect Supabase integration patterns

This narrows model choice less by capability, more by familiarity with Flutter ecosystem.

---

## References

- **Development Roadmap**: `docs/development-roadmap.md`
- **Code Standards**: `docs/code-standards.md`
- **Runbook**: `docs/runbook.md`
