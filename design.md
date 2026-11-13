# Design System

Visual direction inspired by the Posify Mobile UI Kit: a fresh green brand, soft teal-grey neutrals, rounded surfaces, and a clean sans-serif. This file is the single source of truth for colors, typography, spacing, buttons, and scroll behavior. Follow it exactly.

Note: Hex values below were extracted visually from the reference screenshots. Before final implementation, verify each value with an eyedropper on the original Figma file and update this table if any differ.

## 1. Color System

### 1.1 Primary (Green)

| Token | Shade | Hex (approx.) | Usage |
|-------|-------|---------------|-------|
| primary-0 | Lightest mint | `#EAFCF2` | Tinted backgrounds, success banners |
| primary-25 | Very light | `#D3F8E3` | Hover background for light elements |
| primary-50 | Light | `#AAF0C9` | Disabled/soft accents, chips |
| primary-100 | Medium light | `#7DE6AC` | Secondary highlights, illustrations |
| primary-200 | Medium | `#4DDB8F` | Button hover |
| primary-300 | Brand green | `#22C55E` | Default buttons, logo, active icons, links |

### 1.2 Secondary (Teal-Grey)

| Token | Shade | Hex (approx.) | Usage |
|-------|-------|---------------|-------|
| secondary-0 | Lightest | `#E4EEEC` | Card backgrounds, dividers |
| secondary-25 | Very light | `#CCDAD7` | Borders, input outlines |
| secondary-50 | Light | `#9DB3AF` | Placeholder text, inactive icons |
| secondary-100 | Medium | `#6C8A86` | Secondary text |
| secondary-200 | Dark | `#386360` | Secondary buttons, headings on light |
| secondary-300 | Darkest teal | `#052F2C` | Dark surfaces, nav bar accents |

### 1.3 Greyscale

| Token | Hex | Usage |
|-------|-----|-------|
| grey-0 | `#FFFFFF` | Card/surface |
| grey-50 | `#F7F8F8` | App background (light mode) |
| grey-100 | `#EDEEEE` | Section backgrounds |
| grey-200 | `#D9DBDB` | Borders |
| grey-400 | `#9A9E9E` | Muted text |
| grey-600 | `#5A5E5E` | Body text (secondary) |
| grey-800 | `#222424` | Body text (primary) |
| grey-900 | `#111111` | Headings, dark pills |

### 1.4 Status Colors

| Status | Background | Text |
|--------|------------|------|
| Success / Ready | `#EAFCF2` | `#22C55E` |
| Warning / In progress | `#FFF4D6` | `#D99A00` |
| Error | `#FDE8E8` | `#DC2626` |
| Info | `#E6F0FF` | `#2563EB` |

### 1.5 Dark Mode

| Role | Hex |
|------|-----|
| Background | `#171717` |
| Surface / cards | `#232525` |
| Border | `#343737` |
| Primary text | `#FFFFFF` |
| Secondary text | `#A8ADAD` |
| Brand green | `#22C55E` (unchanged) |

**Rules**: Support light and dark mode from day one. Use tokens, never hard-coded hex values in components.

## 2. Typography

Font family: **Manrope** (Google Fonts). Fallback: `system-ui, sans-serif`.

Weights: Regular 400, Medium 500, SemiBold 600, Bold 700.

| Style | Size / Line height | Weight |
|-------|-------------------|--------|
| Heading 1 | 32 / 40 | Bold |
| Heading 2 | 24 / 32 | SemiBold |
| Heading 3 | 20 / 28 | SemiBold |
| Body Large | 16 / 24 | Medium |
| Body | 14 / 20 | Regular |
| Caption | 12 / 16 | Regular |

Headings use grey-900 (light mode) or white (dark mode). Body text uses grey-800 / grey-600.

## 3. Spacing, Radius, Borders

Spacing scale (4px base): **4, 8, 12, 16, 20, 24, 32, 40, 48 px**. Use only these values for padding, margin, and gaps. Default screen side paddings: 16px. Gap between cards: 12px.

### Border radius

| Element | Radius |
|---------|--------|
| Buttons, chips, search bar, tab/nav bar | Fully rounded (pill): `9999px` |
| Cards, list items | `16px` |
| Images inside cards | `16px` |
| Bottom sheets / modals | `24px` top corners |

### Borders

`1px solid secondary-25` (light) or `#343737` (dark). Prefer soft borders over heavy shadows.

### Shadows

Very soft only, e.g. `0 4px 16px rgba(0,0,0,0.06)`.

## 4. Buttons

### 4.1 Shape (the "bowl" shape)

All buttons are pill-shaped: `border-radius: 9999px` (fully rounded ends, like a bowl/capsule). No square or slightly rounded buttons anywhere in the app.

- **Height**: 48px (large/default), 40px (medium), 32px (small).
- **Horizontal padding**: 24px (large), 16px (medium), 12px (small).
- **Icon-only buttons** (e.g. the green "+" add button, cart, notifications): perfect circle, 40-44px.
- **Text**: Manrope SemiBold, 14-16px, centered.
- **Icon + label gap**: 8px.

### 4.2 Variants and states

#### Primary button

| State | Background | Text |
|-------|------------|------|
| Default | primary-300 `#22C55E` | White |
| Hover | primary-200 `#4DDB8F` | White (or grey-900 if contrast is too low) |
| Pressed | `#1AA64D` (darker green) | White |
| Disabled | primary-50 `#AAF0C9` | White at 70% |

#### Secondary (dark pill)

| State | Background | Text |
|-------|------------|------|
| Default | grey-900 `#111111` | White |
| Hover | secondary-200 `#386360` | White |
| Pressed | secondary-300 `#052F2C` | White |

#### Outline / Ghost

| State | Background | Border | Text |
|-------|------------|--------|------|
| Default | Transparent | secondary-25 | grey-900 |
| Hover | primary-0 `#EAFCF2` | primary-300 | primary-300 |
| Pressed | primary-25 | primary-300 | primary-300 |

#### Category chips (Hot Drink, Food, etc.)

- Pill shape, 36px height.
- Unselected: white background, grey-200 border, grey-800 text. Hover: primary-0 background.
- Selected: grey-900 background, white text.

### 4.3 Hover behavior rules

- Hover must change the background color (see tables above). It must never change size or layout.
- Transition: `background-color 200ms ease-in-out` (also for border and text color).
- Mobile touch has no hover. On touch screens, apply the same "hover" color as the pressed state during touch, and return to default on release.
- Hover and pressed states apply to web, tablet, and mouse/stylus users.

## 5. Scroll Reveal (Progressive Content Loading)

Content must not appear all at once. As the user scrolls down, sections and items appear piece by piece.

### 5.1 Behavior

- Each card, list item, and section is hidden initially (opacity 0, shifted down 24px).
- When an element enters the viewport (about 15% visible), it fades in and slides up into place.
- Items within the same group appear with a stagger of 80ms between each (max 5 items staggered per group, then the rest appear together).
- Animation: duration 400ms, easing ease-out.
- Each element animates once only. It stays visible when scrolling back up.
- Above-the-fold content (first screen) animates in on load with the same stagger.
- Respect reduced-motion accessibility settings: if the user has reduced motion enabled, show content instantly without animation.

### 5.2 Data loading (lists)

- Use pagination / lazy loading: load the first 10 items, then load the next 10 when the user is near the bottom (about 200px from end).
- While loading the next batch, show skeleton placeholders (grey rounded rectangles, grey-100, with a subtle shimmer). Skeletons use the same 16px radius as real cards.
- Never block the whole screen with a single spinner for list content.

### 5.3 Implementation reference (Flutter)

Use `VisibilityDetector` (or a `ListView.builder`) with `AnimatedOpacity` + `AnimatedSlide` (400ms, `Curves.easeOut`) per item, triggered once on first visibility. Use `ListView.builder` with `initialChildCount` and pagination triggers.

## 6. Component Notes

- **Search bar**: pill shape, 48px height, grey-50 background, grey-200 border, search icon on left, placeholder in secondary-50.
- **Cards**: white (grey-0) surface, 16px radius, 12-16px padding, soft border or very light shadow.
- **Bottom navigation**: floating dark pill (grey-900), 64px height, 16px margin from screen edges. Active item is a green (primary-300) pill with icon + label; inactive items are icon-only in grey-400.
- **Order status tags**: small pill, status background + status text color from section 1.4.
- **Icons**: outline style, 24px, 1.5px stroke, color grey-800 (inactive) or primary-300 (active).
- **Header**: logo left, circular icon buttons (cart, notifications) right. Notification badge is a small red dot.

## 7. General Rules

- Use design tokens for every color, size, and radius. No magic numbers.
- Every interactive element needs default, hover/pressed, focus, and disabled states.
- Text contrast must meet WCAG AA (4.5:1 for body text). White on `#22C55E` is borderline for small text, so use SemiBold/Bold at 14px or larger.
- Minimum touch target: 44x44px.
- Keep layouts clean with generous whitespace; the green brand color is used sparingly for actions and highlights.
