# Goal-Backward Methodology

**Forward planning asks:** "What should we build?"
**Goal-backward planning asks:** "What must be TRUE for the goal to be achieved?"

Forward planning produces tasks. Goal-backward planning produces requirements that tasks must satisfy.

### Process
1. **Define done state:** What is true when the phase is complete?
2. **Identify must-haves:** Non-negotiable requirements
3. **Decompose to tasks:** What steps achieve each must-have?
4. **Order by dependency:** What must exist before something else?
5. **Group into plans:** 2-3 related tasks per plan

### Must-Haves Structure
```yaml
must_haves:
  truths:
    - "User can log in with valid credentials"
    - "Invalid credentials are rejected with 401"
  artifacts:
    - "src/app/api/auth/login/route.ts exists"
    - "JWT cookie is httpOnly"
  key_links:
    - "Login endpoint validates against User table"
```

---
