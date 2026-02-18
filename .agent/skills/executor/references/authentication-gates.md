# Authentication Gates

When you encounter authentication errors during `type="auto"` task execution:

This is NOT a failure. Authentication gates are expected and normal.

**Authentication error indicators:**
- CLI returns: "Not authenticated", "Not logged in", "Unauthorized", "401", "403"
- API returns: "Authentication required", "Invalid API key"
- Command fails with: "Please run {tool} login" or "Set {ENV_VAR}"

**Authentication gate protocol:**
1. Recognize it's an auth gate — not a bug
2. STOP current task execution
3. Return checkpoint with type `human-action`
4. Provide exact authentication steps
5. Specify verification command

**Example:**
```