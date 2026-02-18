# Debugging Techniques

### Rubber Duck Debugging
**When:** Stuck, confused, mental model doesn't match reality.

Write or say:
1. "The system should do X"
2. "Instead it does Y"
3. "I think this is because Z"
4. "The code path is: A → B → C → D"
5. "I've verified that..." (list what you tested)
6. "I'm assuming that..." (list assumptions)

Often you'll spot the bug mid-explanation.

### Minimal Reproduction
**When:** Complex system, many moving parts.

1. Copy failing code to new file
2. Remove one piece
3. Test: Does it still reproduce? YES = keep removed. NO = put back.
4. Repeat until bare minimum
5. Bug is now obvious in stripped-down code

### Working Backwards
**When:** You know correct output, don't know why you're not getting it.

1. Define desired output precisely
2. What function produces this output?
3. Test that function with expected input — correct output?
   - YES: Bug is earlier (wrong input)
   - NO: Bug is here
4. Repeat backwards through call stack

### Differential Debugging
**When:** Something used to work and now doesn't.

**Time-based:** What changed in code? Environment? Data? Config?

**Environment-based:** Config values? Env vars? Network? Data volume?

### Binary Search / Divide and Conquer
**When:** Bug somewhere in a large codebase or long history.

1. Find a known good state
2. Find current bad state
3. Test midpoint
4. Narrow: is midpoint good or bad?
5. Repeat until found

### Comment Out Everything
**When:** Many possible interactions, unclear which causes issue.

1. Comment out everything in function
2. Verify bug is gone
3. Uncomment one piece at a time
4. When bug returns, you found the culprit

---
