# Mobile Flutter — UI design rules

These rules are **strict** for all UI work in this folder.

## Forbidden

- **Do not use blue or purple** (primary UI, accents, links, highlights, charts, etc.).

## Color palette

| Role | Dark mode | Light mode |
|------|-----------|------------|
| **Background** | `#0f0f0f` | `#f5f5f5` |
| **Card / surface** | `#1c1c1c` | `#ffffff` |

**Accent** — pick **one** per screen or app theme (stay consistent):

- **Orange:** `#f97316`
- **Emerald:** `#10b981`

## Text

- **Dark theme:** white / light gray on dark backgrounds.
- **Light theme:** dark gray / near-black on light backgrounds.

## Style

- Minimal layout and chrome.
- Clean, consistent spacing.
- Rounded corners on cards, buttons, and inputs.
- Soft, subtle shadows (no harsh elevation).

## Avoid

- Overdesign (extra borders, noisy patterns, clutter).
- Bright or multi-stop gradients.

---

*Changes to this document should be rare and intentional; update the Cursor rule in `.cursor/rules/` if the palette or constraints change.*
