# Budget Tracking Protocol

### Before Each Task

1. **Estimate current usage:**
   - Count files in context
   - Estimate tokens per file
   - Calculate approximate %

2. **Check budget status:**
   ```
   Current: ~X,000 tokens (~Y%)
   Budget: [PEAK|GOOD|DEGRADING|POOR]
   ```

3. **Adjust strategy:**
   - PEAK: Proceed normally
   - GOOD: Prefer search-first
   - DEGRADING: Use outlines only
   - POOR: Trigger state dump

### During Execution

Track cumulative context:

```markdown