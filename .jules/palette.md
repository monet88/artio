## 2026-04-07 - Semantics for Interactive GestureDetector Cards
**Learning:** In Flutter, using `GestureDetector` for custom interactive elements like template cards does not automatically provide accessibility semantics (unlike built-in buttons). This leaves screen reader users without context about the element's interactivity or purpose.
**Action:** Always wrap `GestureDetector` interactive cards in a `Semantics` widget with `button: true` and a descriptive `label` (e.g., 'View [Item] template') to ensure proper screen reader support.
## 2024-05-18 - Improve Interactive Element Accessibility in Flutter
**Learning:** In Flutter, `GestureDetector` widgets do not automatically provide accessibility semantics (unlike built-in buttons like `ElevatedButton` or `TextButton`). Using them for interactive elements without a `Semantics` wrapper causes screen readers to ignore them, making the UI inaccessible for users with visual impairments.
**Action:** When using `GestureDetector` for interactive elements (such as links or custom cards), always wrap it in a `Semantics` widget with properties like `button: true` and a descriptive `label` to ensure proper screen reader support.
## 2024-05-18 - Semantics for Custom InkWell Buttons
**Learning:** Custom interactive elements using `InkWell` without built-in button wrappers lack accessibility semantics by default, making them difficult to interact with using screen readers.
**Action:** When building custom buttons using `InkWell`, always wrap them in a `Semantics` widget with `button: true` and a descriptive `label` so screen reader users understand their purpose and interactivity.
