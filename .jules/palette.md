## 2025-03-04 - Accessibility semantics for InkWell
**Learning:** `InkWell` components in Flutter do not automatically provide accessibility semantics by default (unlike built-in `ElevatedButton`, `TextButton`, etc.). This causes screen readers to potentially skip interactive areas built with `InkWell`.
**Action:** Always wrap `InkWell` widgets in a `Semantics` widget with `button: true` and an appropriate descriptive `label` to ensure correct screen reader behavior.
