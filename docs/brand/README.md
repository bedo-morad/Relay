# Relay — Brand Guide

**World:** Deep Lapis + Warm Sand + Muted Amber (Pro) — Dark-first
**Version:** 1.0
**Date:** 2026-08-27

---

## 1. Personality

Warm Human + Calm Utility. Premium treatment is reserved for the paywall. Rounded 16px, soft shadows, trustworthy and approachable. No green, no sharp corporate navy.

---

## 2. Palette

| Role | Dark | Light |
|---|---|---|
| BG | `#0B1220` | `#FDFBF6` |
| Surface | `#131E32` | `#FFFFFF` |
| Border | `#2A3F5F` | `#E2E8F0` |
| Text | `#F8FAFC` / `#CBD5E1` | `#0F172A` / `#475569` |
| Primary | `#1E3A5F` | `#1E3A5F` |
| Pro | `#E8A42C` | `#C88A14` |

Full specification: [`palette.md`](palette.md).

---

## 3. Typography

- **Latin:** Inter 400/600/700, headings 700, tracking `-0.03em`
- **Arabic:** Tajawal 400/700, line-height 1.7, RTL

No embedded text in images. All interface strings are localizable.

---

## 4. Icon

- **Concept:** Interlinked Loop — two pills interlocked, 2.2px stroke, 5px radius, RTL-safe, no arrows, no text.
- **Geometry:** `viewBox 0 0 32 32`, pill1 `5,8,14,10 rx5`, pill2 `13,14,14,10 rx5`
- **Sizes:** 1024 / 512 / 192 / 48 / 180 / 32 / 16 + `favicon.ico`
- **Prompts:** [`icon-prompts.md`](icon-prompts.md)
- **Wordmark:** `Relay` in Inter 700 with 32px icon. No Arabic wordmark.

---

## 5. Privacy System

Icons and colors are always used together with a text label.

- **Public:** `fa-regular fa-eye` — `public #1E3A5F/#DBEAFE/#3B82F6` / `#DBEAFE/#1E3A5F/#93C5FD`
- **Protected:** `fa-solid fa-lock` — `protected #3A2E12/#FDE68A/#E8A42C` / `#FEF3C7/#92400E/#FCD34D`
- **Private:** `fa-solid fa-user-lock` — `private #1F242E/#CBD5E1/#475569` / `#E2E8F0/#1E293B/#CBD5E1`

---

## 6. Banners

- **Header:** 2400x400 master, safe 1200x200, dark `#0B1220` and light `#FDFBF6` variants
- **Open Graph:** 2400x1260 master → 1200x630 / 1200x675 / 1280x640, safe 600px center

Style: soft flat vector, warm, subtle grain, rounded, 2–3 colors, no text. Prompts: [`banner-prompts.md`](banner-prompts.md).

---

## 7. Imagery Style

Soft flat vector, warm, subtle grain, rounded shapes, soft shadows, minimal. Light variants use the same composition with the background swapped.

---

## 8. Usage Rules

- Centered, rounded, 1–2 accent colors maximum, WCAG AA in both themes, RTL-safe, responsive.
- Avoid green, arrows, code brackets, embedded text, Pro amber outside the paywall, busy gradients or 3D.

---

## 9. Files

- `docs/brand/palette.md` — palette and tokens
- `docs/brand/tokens.json` — machine-readable tokens
- `docs/brand/icon-prompts.md` — icon generation
- `docs/brand/banner-prompts.md` — banner generation
