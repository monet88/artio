---
description: Plan and implement UI using Stitch MCP with enhance-prompt and design-md skills
---

# UI/UX Pro Max — Stitch MCP Workflow

Design, generate, and iterate on UI screens using Stitch MCP server with design system consistency.

## Prerequisites

- Stitch MCP server connected (verify: `mcp_stitch_list_projects`)
- Skills loaded: `enhance-prompt`, `design-md`

---

## Phase 1: Setup & Context

1. **Understand the request** — What screens/pages does the user need?

2. **Check for existing Stitch project:**
   ```
   mcp_stitch_list_projects
   ```
   - If project exists → get project ID, list screens
   - If no project → create one in Phase 2

3. **Check for DESIGN.md** in the project root:
   - If exists → read it for design system context
   - If not → will create in Phase 3 after first screen

4. **Read the Stitch prompting guide** for latest best practices:
   ```
   read_url_content: https://stitch.withgoogle.com/docs/learn/prompting/
   ```

---

## Phase 2: Project Setup (if needed)

// turbo
1. **Create Stitch project:**
   ```
   mcp_stitch_create_project(title: "<project name>")
   ```

2. Note the project ID from the response for all subsequent calls.

---

## Phase 3: Design System (first time only)

If no DESIGN.md exists yet:

1. **Generate first screen** to establish visual direction (Phase 4)

2. **Extract design system** using `design-md` skill:
   - Read the SKILL.md: `.agent/skills/design-md/SKILL.md`
   - Get screen details:
     ```
     mcp_stitch_get_screen(projectId, screenId)
     ```
   - Download HTML from `htmlCode.downloadUrl`
   - Get project theme from `mcp_stitch_get_project`
   - Analyze colors, typography, components, layout
   - Write `DESIGN.md` to project root

3. Use `DESIGN.md` for all future screen generation prompts.

---

## Phase 4: Generate Screens

For each screen the user needs:

1. **Enhance the prompt** using `enhance-prompt` skill:
   - Read skill: `.agent/skills/enhance-prompt/SKILL.md`
   - Read `references/KEYWORDS.md` for UI/UX vocabulary
   - Take user's description → enhance with:
     - Platform specification (mobile/desktop)
     - Page structure (numbered sections)
     - UI/UX keywords (specific component names)
     - Design system from DESIGN.md (if exists)
     - Color values with hex codes and roles
     - Visual style descriptors

2. **Present enhanced prompt** to user for approval/tweaks.

3. **Generate the screen:**
   ```
   mcp_stitch_generate_screen_from_text(
     projectId: "<id>",
     prompt: "<enhanced prompt>",
     deviceType: "MOBILE"  // or DESKTOP, TABLET
   )
   ```
   ⚠️ This can take a few minutes. DO NOT RETRY.

4. **Review output_components** from the response:
   - If contains suggestions → present to user
   - If user accepts a suggestion → call generate again with that suggestion as prompt

---

## Phase 5: Iterate & Refine

If the user wants changes to existing screens:

1. **List current screens:**
   ```
   mcp_stitch_list_screens(projectId: "<id>")
   ```

2. **For edits** (modify existing screen):
   ```
   mcp_stitch_edit_screens(
     projectId: "<id>",
     selectedScreenIds: ["<screen_id>"],
     prompt: "<what to change>"
   )
   ```

3. **For variants** (explore alternatives):
   ```
   mcp_stitch_generate_variants(
     projectId: "<id>",
     selectedScreenIds: ["<screen_id>"],
     prompt: "<variation direction>",
     variantOptions: { "numVariants": 3 }
   )
   ```

4. **Get screen details** to review:
   ```
   mcp_stitch_get_screen(projectId, screenId)
   ```

---

## Phase 6: Export & Integrate

Once designs are approved:

1. **Get final screen HTML:**
   ```
   mcp_stitch_get_screen → download htmlCode.downloadUrl
   ```

2. **For Flutter (Artio):**
   - Use the Stitch output as visual reference
   - Implement the design in Flutter widgets following project patterns
   - Match colors, spacing, typography from DESIGN.md
   - Follow `.gsd/ARCHITECTURE.md` for component placement

3. **Update DESIGN.md** if new patterns were established.

---

## Quick Reference

| Action | Tool |
|--------|------|
| List projects | `mcp_stitch_list_projects` |
| Create project | `mcp_stitch_create_project` |
| List screens | `mcp_stitch_list_screens` |
| Get screen details | `mcp_stitch_get_screen` |
| Generate new screen | `mcp_stitch_generate_screen_from_text` |
| Edit existing screen | `mcp_stitch_edit_screens` |
| Generate variants | `mcp_stitch_generate_variants` |
| Get project info | `mcp_stitch_get_project` |

## Tips

- Always enhance prompts before generating — better input = better output
- Include hex color codes in prompts for precise color matching
- Use numbered page structure for complex layouts
- Generate one screen at a time for better control
- Create DESIGN.md early to maintain consistency across screens
- For Artio: mobile-first (390px width), dark mode preferred