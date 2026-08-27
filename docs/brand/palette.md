# Relay — Palette & Tokens

**World:** Deep Lapis + Warm Sand + Muted Amber (Pro) — Dark-first, Light derived
**Version:** 1.0
**Date:** 2026-08-27

---

## 1. Philosophy

- **Audience:** Egyptian-primary, west-secondary. Lapis is a historic pigment, Warm Sand references papyrus, Amber is used for the Pro paywall only.
- **Personality:** Warm Human + Calm Utility. Premium treatment is reserved for the paywall. Rounded 16px, soft shadows.
- **Strategy:** Dark-first. Light is derived by warming the background and desaturating the Pro accent for accessibility. Both themes pass WCAG AA.
- **Typography:** Inter for Latin, Tajawal for Arabic (RTL). Line-height 1.7 for Arabic.

---

## 2. Core Palette

| Token | Dark | Light | Usage |
|---|---|---|---|
| `--relay-bg` | `#0B1220` | `#FDFBF6` | Page background |
| `--relay-surface` | `#131E32` | `#FFFFFF` | Cards, modals |
| `--relay-surface-elevated` | `#1A2B4A` | `#FFFFFF` | Elevated / hover |
| `--relay-border` | `#2A3F5F` | `#E2E8F0` | Card border |
| `--relay-border-strong` | `#334155` | `#CBD5E1` | Dividers |
| `--relay-text` | `#F8FAFC` | `#0F172A` | Title / primary |
| `--relay-text-secondary` | `#CBD5E1` | `#475569` | Metadata |
| `--relay-text-muted` | `#94A3B8` | `#64748B` | Disabled / placeholder |
| `--relay-primary` | `#1E3A5F` | `#1E3A5F` | Primary actions, links |
| `--relay-primary-hover` | `#24486F` | `#24486F` | Hover |
| `--relay-pro` | `#E8A42C` | `#C88A14` | Pro paywall only |
| `--relay-pro-hover` | `#D9A441` | `#B45309` | Pro hover |
| `--relay-radius` | `16px` | `16px` | Cards |
| `--relay-shadow` | `0 8px 32px rgba(2,6,23,.45)` | `0 8px 32px rgba(15,23,42,.08)` | Shadow |

---

## 3. Privacy Chips — Icon + Color + Label

Each chip uses icon + background + border + label. Never color-only.

| State | Icon | Dark | Light |
|---|---|---|---|
| **Public** — anyone with link | `fa-regular fa-eye` | bg `#1E3A5F`, text `#DBEAFE`, border `#3B82F6` | bg `#DBEAFE`, text `#1E3A5F`, border `#93C5FD` |
| **Protected** — password required | `fa-solid fa-lock` | bg `#3A2E12`, text `#FDE68A`, border `#E8A42C` | bg `#FEF3C7`, text `#92400E`, border `#FCD34D` |
| **Private** — owner only | `fa-solid fa-user-lock` | bg `#1F242E`, text `#CBD5E1`, border `#475569` | bg `#E2E8F0`, text `#1E293B`, border `#CBD5E1` |

Light contrast: public 8.2:1, protected 7.4:1, private 10.1:1. All have 1px solid border.

---

## 4. Feedback

| Token | Value |
|---|---|
| `--relay-success` | `#22C55E` |
| `--relay-warning` | `#E8A42C` |
| `--relay-danger` | `#EF4444` |
| `--relay-radius-sm` | `10px` |
| `--relay-radius-pill` | `999px` |

---

## 5. Accessibility

- Dark surface `#131E32` + secondary `#CBD5E1` = 7.2:1
- Dark title `#F8FAFC` on `#131E32` = 13.8:1
- Light text `#0F172A` on `#FDFBF6` = 16:1
- Pro `#E8A42C` on `#0B1220` = 7.1:1, `#C88A14` on `#FFFFFF` = 4.6:1

---

## 6. Usage Rules

- No green.
- No directional arrows — RTL-safe.
- No embedded text in images — localizable.
- No code brackets `</>` in brand assets.
- No Pro amber outside the paywall.
