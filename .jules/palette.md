## 2025-03-04 - Accessibility semantics for InkWell
**Learning:** `InkWell` components in Flutter do not automatically provide accessibility semantics by default (unlike built-in `ElevatedButton`, `TextButton`, etc.). This causes screen readers to potentially skip interactive areas built with `InkWell`.
**Action:** Always wrap `InkWell` widgets in a `Semantics` widget with `button: true` and an appropriate descriptive `label` to ensure correct screen reader behavior.
## 2025-03-04 - Tooltip and Semantics on custom icon buttons
**Learning:** Adding `Semantics(button: true, label: ...)` to an `InkWell` that only contains an icon is necessary when we are creating custom buttons (like `_GlassIconButton` or a remove icon overlaid on an image). Without it, the screen reader does not announce the action properly.
**Action:** Always wrap custom icon-only interactive elements (like `InkWell` around an `Icon`) in `Semantics` with a descriptive label.
