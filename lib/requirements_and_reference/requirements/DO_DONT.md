# Development & Design: Do's and Don'ts

This document serves as the "Guardrails" for both design and engineering. Adherence to these rules ensures the project maintains its **Atmospheric Precision** North Star.

---

## 🎨 Design & UI (Atmospheric Precision)

### ✅ Do:
- **Use Tonal Layering:** Define boundaries using color shifts (e.g., a `surfaceContainerLowest` card on a `surface` background) instead of borders.
- **Embrace White Space:** Space is a luxury. Elements must have a minimum gutter of **24px (1.5rem)** from the screen edges.
- **Ambient Shadows Only:** Use the custom shadows defined in `AppStyles.ambientShadow`. Shadows should be extra-diffused and tinted with `onSurface`, never pure black.
- **Manrope for Impact:** Use Manrope for headlines to give the UI an architectural, geometric character.
- **Inter for Function:** Use Inter for all UI labels and body text to ensure maximum legibility at small scales.
- **Roundedness:** Use the `radiusXL` (24px) for all large containers and buttons.

### ❌ Don't:
- **No 1px Borders:** Borders are strictly prohibited for containment or sectioning.
- **No Default Drop Shadows:** Do not use default Flutter/Figma shadows.
- **No Pure Black:** Never use `#000000`. Use `AppColors.onSurface` (`#191C1D`) for text.
- **No Cramped Layouts:** If a component feels crowded, double the padding. Never crowd the edges.
- **No Checkmarks for Selection:** Let color shifts (e.g., primary to surface) handle selection status in chips or selectors.

---

## 🛠️ Engineering & Architecture

### ✅ Do:
- **Use Centralized Tokens:** Always use `AppColors.primary`, `AppStyles.bodyMd`, etc. Never hardcode hex values or font sizes in widgets.
- **Leverage Theme Inheritance:** Allow widgets to inherit from `Theme.of(context)` whenever possible (e.g., `Theme.of(context).colorScheme.primary`).
- **Responsive Scaling:** Wrap sizes in `context.sp()` or `context.h()` via the `ResponsiveHelper` to ensure the "Editorial" feel scales across devices.
- **Keep Folders Clean:** Maintain the `requirements_and_reference` folder as the source of truth for new feature logic.

### ❌ Don't:
- **No Ad-hoc Styling:** Avoid `TextStyle(...)` in the UI layer. Update `AppStyles` if a new pattern is required.
- **No Logic in UI:** Keep business logic in Controllers (GetX) or Services. Presentation files should only handle layout and style.
- **No Magic Numbers:** Define constant variables for repeated magic numbers like animation durations or elevation values.

---

## 🏗️ Backend & Data Architecture

### ✅ Do:
- **Use Repository Interfaces:** Always define an interface (e.g., `IProductRepository`) in the Domain layer before implementing data fetching.
- **Support Environment Toggling:** Ensure all repositories have a `Mock` version for local development and a `Firebase` (or other) version for production.
- **Dependency Injection:** Inject repositories via `Get.find<IInterface>()` in controllers to maintain backend agnosticism.
- **Mock First:** When building a new feature, implement the `MockRepository` first to validate the UI before writing backend integration code.

### ❌ Don't:
- **No Direct Firebase in UI:** Never import `cloud_firestore` or `firebase_auth` in a Widget or Controller. All backend calls must stay in the Data layer.
- **No Shared Repository Context:** Repositories should be stateless or handle their own internal data streams.
