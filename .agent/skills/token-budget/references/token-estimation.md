# Token Estimation

### Quick Estimates

| Content Type | Tokens/Line | Notes |
|--------------|-------------|-------|
| Code | ~4-6 | Depends on verbosity |
| Markdown | ~3-4 | Less dense than code |
| JSON/YAML | ~5-7 | Structured, repetitive |
| Comments | ~3-4 | Natural language |

**Rule of thumb:** `tokens ≈ lines × 4`

### File Size Categories

| Category | Lines | Est. Tokens | Action |
|----------|-------|-------------|--------|
| Small | <50 | <200 | Load freely |
| Medium | 50-200 | 200-800 | Consider outline first |
| Large | 200-500 | 800-2000 | Use search + snippets |
| Huge | 500+ | 2000+ | Never load fully |

---
