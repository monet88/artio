# Design Guidelines

## Design Direction

Artio should feel like a focused creative tool, not a generic dashboard.
The UI should communicate generation, credits, and asset management clearly
without looking like a default template.

## Main App

- Use the existing theme tokens and design-system primitives.
- Preserve clear hierarchy between create flows, gallery, and account state.
- Keep premium, credit, and generation states visually obvious.
- Use purposeful motion only where it clarifies state or progress.
- Keep empty, error, and loading states informative instead of decorative.

## Admin App

- Prefer compact, operational layouts.
- Keep navigation simple and stable.
- Make template management fast to scan and edit.
- Favor density and clarity over flourish.

## Consistency Rules

- Avoid hardcoded colors and spacing where shared tokens already exist.
- Keep button, card, and surface styling consistent inside each surface.
- Use semantic color meaning for success, warning, error, and premium states.
- Keep typography readable at the small sizes common in admin and mobile UI.

## Accessibility

- Preserve readable contrast in light and dark themes.
- Ensure focus states are visible.
- Keep touch targets large enough for mobile use.
- Keep state changes understandable without color alone.

## Notes

This guide is intentionally short. It captures the current design intent from
code, not a separate brand system.
