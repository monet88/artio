# Compression Format Templates

## Summary Template

```markdown
## 📦 [filename]
**Purpose:** [one line]
**Key exports:** [list]
**Dependencies:** [list]
**Patterns:** [notable patterns used]
**Watch for:** [gotchas or edge cases]
```

## Outline Template

```markdown
## 📋 [filename] (N lines)
- L[start]-[end]: [section name]
  - L[n]: [key item]
  - L[n]: [key item]
```

## Diff Template

```markdown
## Δ [filename]
**+** [additions]
**-** [removals]
**~** [modifications]
```

## Decompression Log

```markdown
| File | Reason | Level | Tokens |
|------|--------|-------|--------|
| auth.ts | Debug login | L2 (func) | +150 |
| db.ts | Check query | L3 (snippet) | +50 |
```
