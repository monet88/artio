# Anti-Patterns

### ❌ Loading Everything First

```
# BAD: Reading 5 full files to "understand context"
Read: src/auth/login.ts (500 lines)
Read: src/auth/register.ts (400 lines)
Read: src/auth/types.ts (200 lines)
```

### ✅ Search Then Target

```
# GOOD: Search first, read only what's needed
Search: "validatePassword" in src/auth/
Found: login.ts:45, register.ts:78
Read: login.ts lines 40-60
```

### ❌ Broad Searches

```
# BAD: Searching for common terms
Search: "function" → 10,000 results
```

### ✅ Specific Searches

```
# GOOD: Searching for specific identifiers
Search: "validateUserCredentials" → 3 results
```

---
