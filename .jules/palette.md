## 2026-03-31 - [Icon Button Tooltips]
**Learning:** In Flutter, icon-only buttons like `IconButton` require the `tooltip` property to provide a semantic label for screen readers. Without it, the interactive element lacks an accessible name, making it difficult for visually impaired users to understand the button's purpose.
**Action:** Always ensure `IconButton` and similar icon-only interactive widgets include a descriptive `tooltip` attribute.
## 2024-06-05 - Add tooltips to icon-only buttons
**Learning:** Interactive elements that only display an icon (like InkWell around Icons.close) must be wrapped in a Tooltip or Semantics label. Without it, screen readers announce nothing, preventing visually impaired users from understanding the button's action.
**Action:** Always wrap icon-only interactive components with a Tooltip widget which provides both visual hover cues and accessibility label.
## 2024-10-24 - Semantics for GestureDetector
**Learning:** In Flutter, `GestureDetector` widgets do not automatically provide accessibility semantics (unlike built-in buttons). When wrapping interactive elements (like image previews) with `GestureDetector`, screen readers cannot announce them properly.
**Action:** Wrap `GestureDetector` widgets used for interactive elements in a `Semantics` widget with `button: true` and an appropriate descriptive `label` to provide equivalent accessibility to standard buttons.
