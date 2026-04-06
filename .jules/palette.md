## $(date +%Y-%m-%d) - Semantics for Interactive GestureDetector Cards
**Learning:** In Flutter, using `GestureDetector` for custom interactive elements like template cards does not automatically provide accessibility semantics (unlike built-in buttons). This leaves screen reader users without context about the element's interactivity or purpose.
**Action:** Always wrap `GestureDetector` interactive cards in a `Semantics` widget with `button: true` and a descriptive `label` (e.g., 'View [Item] template') to ensure proper screen reader support.
