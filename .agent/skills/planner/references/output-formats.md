# Output Formats

### Standard Mode
```
PLANS_CREATED: {N}
WAVE_STRUCTURE:
  Wave 1: [plan-1, plan-2]
  Wave 2: [plan-3]
FILES: [list of PLAN.md paths]
```

### Gap Closure Mode
```
GAP_PLANS_CREATED: {N}
GAPS_ADDRESSED: [gap-ids]
FILES: [list of gap PLAN.md paths]
```

### Checkpoint Reached
```
CHECKPOINT: {type}
QUESTION: {what needs user input}
OPTIONS: [choices if applicable]
```

---
