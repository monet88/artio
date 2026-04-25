## 2025-03-04 - Accessibility semantics for InkWell
**Learning:** `InkWell` components in Flutter do not automatically provide accessibility semantics by default (unlike built-in `ElevatedButton`, `TextButton`, etc.). This causes screen readers to potentially skip interactive areas built with `InkWell`.
**Action:** Always wrap `InkWell` widgets in a `Semantics` widget with `button: true` and an appropriate descriptive `label` to ensure correct screen reader behavior.
## 2025-03-04 - Tooltip and Semantics on custom icon buttons
**Learning:** Adding `Semantics(button: true, label: ...)` to an `InkWell` that only contains an icon is necessary when we are creating custom buttons (like `_GlassIconButton` or a remove icon overlaid on an image). Without it, the screen reader does not announce the action properly.
**Action:** Always wrap custom icon-only interactive elements (like `InkWell` around an `Icon`) in `Semantics` with a descriptive label.
## 2025-03-04 - UX pattern for destructive dialog actions
**Learning:** Using a simple `TextButton` with red text for destructive actions (like "Delete") in dialogs provides weak visual distinction and poor accessibility cues for critical actions.
**Action:** Use a `FilledButton` (or `FilledButton.icon` to be even clearer) with a strong color background (e.g., `Colors.red`) and contrasting text (`Colors.white`) for destructive actions to ensure users clearly recognize the severity of the action before confirming.
## 2025-03-04 - Dynamic Semantics for Loading States
**Learning:** Screen readers and mouse users lose context when a button's content changes to a generic loading spinner (like `CircularProgressIndicator`) without corresponding semantic label or tooltip updates.
**Action:** When swapping an icon or text for a loading indicator in an interactive element, dynamically update its `Semantics` label or `Tooltip` (e.g., `tooltip: isSharing ? 'Sharing...' : 'Share'`) to clearly communicate the async state.
