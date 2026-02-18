# Process

### Step 1: Define the Question

What are you trying to find or understand?

Examples:
- "Where is the login endpoint defined?"
- "How does the caching layer work?"
- "What calls the `processPayment` function?"

### Step 2: Identify Keywords

Extract searchable terms:

| Question | Keywords |
|----------|----------|
| Login endpoint | `login`, `auth`, `POST.*login` |
| Caching layer | `cache`, `redis`, `memoize` |
| Payment calls | `processPayment`, `payment` |

### Step 3: Search Before Reading

**PowerShell:**
```powershell
# Simple pattern search
Select-String -Path "src/**/*.ts" -Pattern "login" -Recurse

# With ripgrep (if available)
rg "login" --type ts
```

**Bash:**
```bash
# With ripgrep (recommended)
rg "login" --type ts

# With grep
grep -r "login" src/ --include="*.ts"
```

### Step 4: Evaluate Results

From search results, identify:

1. **Primary candidates** — Files directly matching your question
2. **Secondary candidates** — Files that reference primary candidates
3. **Ignore list** — Files with keyword but unrelated context

### Step 5: Targeted Reading

Only read what's justified:

```powershell
# Read specific line range (PowerShell)
Get-Content "src/auth/login.ts" | Select-Object -Skip 49 -First 30

# Read specific function (with view_code_item tool)
# view_code_item: src/auth/login.ts -> handleLogin
```

---
