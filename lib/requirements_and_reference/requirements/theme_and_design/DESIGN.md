# Design System Specification: Atmospheric Precision

## 1. Overview & Creative North Star
The vision for this design system is **"Atmospheric Precision."** We are moving away from the "boxed-in" feel of standard mobile templates to create an experience that feels like a high-end digital editorial. 

Instead of relying on rigid grids and heavy borders to define space, we use **Tonal Layering** and **Intentional Asymmetry**. The goal is to provide a sense of "breathable" luxury where the UI feels like a series of soft, physical layers. By utilizing high-contrast typography scales and overlapping elements, we create a signature visual identity that feels custom-built for a premium community platform.

---

## 2. Colors & Surface Logic
The palette is rooted in a refined orchestration of the primary indigo (`#5C6BC0`) balanced against sophisticated neutrals.

### The Palette (Core Tokens)
*   **Primary:** `#4352a5` (The authoritative brand voice)
*   **Primary Container:** `#5C6BC0` (Used for primary actions and hero accents)
*   **Surface:** `#f8f9fa` (The base canvas)
*   **Surface Container (Lowest to Highest):** `#ffffff` to `#e1e3e4` (The layering engine)
*   **On-Surface:** `#191c1d` (High-contrast text for maximum readability)

### The "No-Line" Rule
Standard 1px borders are strictly prohibited for sectioning or containment. Boundaries must be defined through **Background Color Shifts**. 
*   *Example:* A `surface_container_low` card should sit on a `surface` background. The change in tone provides the boundary, creating a softer, more integrated aesthetic.

### Glass & Gradient Logic
To avoid a flat "flat-design" look, use subtle gradients for primary elements. Transition from `primary` to `primary_container` across a 45-degree axis for main CTAs. For floating headers or overlays, apply **Glassmorphism**: use semi-transparent surface colors with a `20px` backdrop-blur to allow the background soul to bleed through.

---

## 3. Typography
This system utilizes a dual-font strategy to balance editorial character with functional clarity.

*   **Display & Headlines (Manrope):** These are the "Editorial" voices. Use high-contrast sizing (e.g., `display-lg` at 3.5rem) to create clear entry points. The geometric nature of Manrope provides a modern, architectural feel.
*   **Body & UI (Inter):** Inter is used for all functional text. It is chosen for its exceptional legibility at small scales in mobile environments.

**Hierarchy Tip:** Always pair a `headline-md` with `body-sm` in a different tonal weight (e.g., `on_surface_variant`) to create a clear "Title/Caption" relationship without needing lines.

---

## 4. Elevation & Depth
Depth is not an afterthought; it is the structural backbone of the UI.

### The Layering Principle
Hierarchy is achieved by "stacking" surface tiers.
1.  **Level 0 (Base):** `surface` (`#f8f9fa`)
2.  **Level 1 (Sections):** `surface_container_low` (`#f3f4f5`)
3.  **Level 2 (Interactive Cards):** `surface_container_lowest` (`#ffffff`)

### Ambient Shadows
When a "floating" effect is required (e.g., the Register button), use extra-diffused shadows.
*   **Shadow Specs:** `Blur: 24px`, `Spread: -4px`, `Opacity: 6%`.
*   **Shadow Color:** Use a tinted version of `on_surface` rather than pure black to keep the light source feeling natural and ambient.

### The "Ghost Border"
If a border is required for accessibility (such as input field focus), use a "Ghost Border": the `outline_variant` token at **15% opacity**. Never use a 100% opaque border for decorative containment.

---

## 5. Components

### Primary Buttons
*   **Style:** `primary` background with a subtle linear gradient to `primary_container`.
*   **Rounding:** `full` (9999px) or `xl` (1.5rem) for a friendly, premium feel.
*   **State:** On press, increase depth by shifting to a slightly darker `on_primary_fixed_variant`.

### Account Type Selectors (Selection Chips)
*   **Unselected:** `surface_container_high` background with `on_surface_variant` text.
*   **Selected:** `primary_fixed` background with `on_primary_fixed` text.
*   **Interaction:** Use a subtle "pop" animation (scale 1.02) to signify selection. Avoid using a checkmark icon; let the color shift do the work.

### Input Fields
*   **Visuals:** Eschew the four-sided box. Use a `surface_container_low` background with a `0.5rem` (DEFAULT) rounded top and a 2px `primary` underline only upon focus.
*   **Spacing:** Increase vertical padding to `1.25rem` to give text more "breathing room," aligning with the editorial aesthetic.

### Cards & Lists
*   **Prohibition:** Dividers/Lines are forbidden.
*   **Structure:** Separate list items using vertical white space (from the `lg` spacing scale) or by placing each item in its own `surface_container_lowest` tile on a `surface_container_low` background.

---

## 6. Do's and Don'ts

### Do:
*   **Use Generous White Space:** Treat space as a luxury. If a component feels cramped, double the padding.
*   **Leverage Tonal Contrast:** Ensure all "On-Surface" text maintains a high contrast ratio (minimum 4.5:1) against its background tier.
*   **Embrace Roundedness:** Use the `xl` (1.5rem) rounding for large containers (like the "Create Account" card) to soften the mobile experience.

### Don't:
*   **Don't use pure black (#000000):** Use `on_surface` (`#191c1d`) for text and `inverse_surface` for dark modes to maintain tonal warmth.
*   **Don't use default shadows:** Never use the "Drop Shadow" defaults in design software. Always customize the blur and opacity to meet the "Ambient" criteria.
*   **Don't crowd the edges:** Elements should never touch the edge of the screen. Maintain a minimum gutter of `1.5rem`.