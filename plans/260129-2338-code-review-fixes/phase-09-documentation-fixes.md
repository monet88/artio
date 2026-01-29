# Phase 09: Documentation Fixes

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | D (Docs) |
| Can Run With | Any phase |
| Blocked By | None |
| Blocks | None |

## File Ownership (Exclusive)

- `docs/gemini/image-generation.md`

## Priority: LOW

**Issue**: Documentation contains internal codenames ("Nano Banana") that should use public product names.

## Identified Issues

### Internal Codenames to Fix

| Line | Current Text | Fix |
|------|--------------|-----|
| 5 | `(aka Nano Banana)` and `(aka Nano Banana Pro)` | Remove internal codenames |
| 24-25 | `"nano banana dish"` | `"gourmet dish"` |
| 48-49 | `"nano banana dish"` | `"gourmet dish"` |
| 92-93 | `"nano banana dish"` | `"gourmet dish"` |
| 128 | `"nano banana dish"` | `"gourmet dish"` |
| 154 | `"nano banana dish"` | `"gourmet dish"` |
| 181-183 | `"eating a nano-banana"` | `"eating a banana"` |
| 213-214 | `"eating a nano-banana"` | `"eating a banana"` |
| 265 | `"eating a nano-banana"` | `"eating a banana"` |
| 319-322 | `"eating a nano-banana"` | `"eating a banana"` |
| 362 | `"eating a nano-banana"` | `"eating a banana"` |
| 376 | `"anano banana"` typo in alt text | `"a banana"` |

### Markdown Syntax Issues

| Line | Issue | Fix |
|------|-------|-----|
| 5 | Missing space: `the[fast` | `the [fast` |
| 5 | Missing space: `]image` | `] image` |
| 376 | Typo: `anano` | `a` |

## Implementation Steps

### Step 1: Fix Line 5 Model Description

**Current**:
```markdown
You can prompt either the[fast Gemini 2.5 Flash (aka Nano Banana) or the advanced Gemini 3 Pro Preview (aka Nano Banana Pro)](https://ai.google.dev/gemini-api/docs/image-generation#model-selection)image models
```

**Fixed**:
```markdown
You can prompt either the [fast Gemini 2.5 Flash or the advanced Gemini 3 Pro Preview](https://ai.google.dev/gemini-api/docs/image-generation#model-selection) image models
```

### Step 2: Replace Prompt Examples

Use sed or manual replacement:
```bash
# Replace "nano banana dish" with "gourmet dish"
sed -i 's/nano banana dish/gourmet dish/g' docs/gemini/image-generation.md

# Replace "nano-banana" with "banana"
sed -i 's/nano-banana/banana/g' docs/gemini/image-generation.md

# Fix typo "anano"
sed -i 's/anano banana/a banana/g' docs/gemini/image-generation.md
```

### Step 3: Fix Alt Text (Line 376)

**Current**:
```markdown
![AI-generated image of a cat eating anano banana](https://ai.google.dev/...)
```

**Fixed**:
```markdown
![AI-generated image of a cat eating a banana](https://ai.google.dev/...)
```

## Success Criteria

- [ ] No internal codenames ("Nano Banana") in documentation
- [ ] All markdown syntax valid (proper spacing around links)
- [ ] Alt text typos fixed
- [ ] Document renders correctly in markdown preview

## Conflict Prevention

- Only this phase modifies `docs/gemini/` directory
- No code dependencies

## Notes

- External image URLs (google.dev) remain unchanged
- Go SDK examples are from Google documentation - error handling style is intentional for brevity
