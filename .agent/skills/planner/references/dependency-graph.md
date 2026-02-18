# Dependency Graph

### Building Dependencies
1. Identify shared resources (files, types, APIs)
2. Determine creation order (types before implementations)
3. Group independent work into same wave
4. Sequential dependencies go to later waves

### Wave Assignment
- **Wave 1:** Foundation (types, schemas, utilities)
- **Wave 2:** Core implementations
- **Wave 3:** Integration and validation

### Vertical Slices vs Horizontal Layers
**Prefer vertical slices:** Each plan delivers a complete feature path.

```
✅ Vertical (preferred):
Plan 1: User registration (API + DB + validation)
Plan 2: User login (API + session + cookie)

❌ Horizontal (avoid):
Plan 1: All database models
Plan 2: All API endpoints
```

### File Ownership for Parallel Execution
Plans in the same wave MUST NOT modify the same files.

If two plans need the same file:
1. Move one to a later wave, OR
2. Split the file into separate modules

---
