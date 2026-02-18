# Scanning Process

### Phase 1: Project Type Detection

Identify project type from markers:
```powershell
# Node.js/JavaScript
Test-Path "package.json"

# Python
Test-Path "requirements.txt" -or Test-Path "pyproject.toml"

# Rust
Test-Path "Cargo.toml"

# Go
Test-Path "go.mod"

# .NET
Get-ChildItem "*.csproj"
```

### Phase 2: Structure Scan

```powershell
# Get directory structure
Get-ChildItem -Recurse -Directory | 
    Where-Object { $_.Name -notmatch "node_modules|\.git|__pycache__|dist|build|\.next" } |
    Select-Object FullName
```

### Phase 3: Dependency Extraction

For each ecosystem:

**Node.js:**
```powershell
$pkg = Get-Content "package.json" | ConvertFrom-Json
$pkg.dependencies
$pkg.devDependencies
```

**Python:**
```powershell
Get-Content "requirements.txt"
```

### Phase 4: Pattern Discovery

Search for common patterns:
```powershell
# Components
Get-ChildItem -Recurse -Include "*.tsx","*.jsx" | Select-Object Name

# API routes
Get-ChildItem -Recurse -Path "**/api/**" -Include "*.ts","*.js"

# Models/schemas
Select-String -Path "**/*.ts" -Pattern "interface|type|schema"
```

### Phase 5: Debt Discovery

```powershell
# TODOs
Select-String -Path "src/**/*" -Pattern "TODO|FIXME|HACK|XXX"

# Deprecated
Select-String -Path "**/*" -Pattern "@deprecated|DEPRECATED"

# Console statements (often debug leftovers)
Select-String -Path "src/**/*" -Pattern "console\.(log|debug|warn)"
```

---
