# Full App Requirements: Indigo Commons (Vendor Portal)

This document outlines the end-to-end requirements for the Indigo Commons Vendor Portal, incorporating the "Atmospheric Precision" design system and the specific feature references provided.

## 1. Core Design Pillars (Atmospheric Precision)
- **Typography:** Manrope (Display), Inter (Functional).
- **Surface Logic:** Layered depth (Level 0-2) using color shifts, not borders.
- **Color Palette:** Primary `#4352a5`, Surface `#f8f9fa`, On-Surface `#191c1d`.
- **Navigation:** Full-width glassmorphism bottom nav (Dashboard, Deliveries, Customers, Catalog).

---

## 2. Feature Roadmap

### Phase 1: Dashboard Overhaul
- **Top Bar:** Glassmorphism AppBar with a side drawer trigger.
- **Side Drawer:** Vendor profile (Admin name, Business type), Profile, Subscription, Billing, Support links.
- **Greeting Section:** "Hello, Central Hub" with period selectors (Today/Weekly/Custom).
- **Metrics Grid:** 
    - Total Deliveries (Gradient card with shipping icon).
    - Pending Deliveries (Surface Low card with progress indicator).
    - Completed Deliveries (Surface Lowest card with scheduled indicator).
- **Operational Summary:**
    - Earnings Card: Circular goal progress (75% completion visualize).
    - Active Route Card: Customer stack (avatars) and route metadata (12 drops, 45 mins).

### Phase 2: Active Deliveries (Route View)
- **Context:** View for the current delivery run.
- **Search & Filters:** Real-time search by customer address + Pills (All, Pending, Delivered, Skipped).
- **Delivery Timeline:** 
    - Vertical list of delivery cards.
    - High-impact CTA (Delivered button).
    - Status badges (Pending, Skip Requested).

### Phase 3: Delivery Details
- **Customer Context:** Receipt name, priority tag, address, and interactive gate/entry notes.
- **Item Breakdown:** Grid of products with high-quality images and quantities (`x1`, `x2`).
- **Confirmation Flow:** Global "Confirm Delivery" CTA with background notification logic.

### Phase 4: Product Catalog (Inventory)
- **Stats:** Active products, Top performers, Low stock alerts.
- **Catalog List:** List of items with price, unit metadata, and categorization.
- **Management:** Floating Action Button (FAB) for "Add New Product" + Edit flow.

---

## 3. Implementation Checklist

- [ ] **Global Overlay:** Implement the side drawer and common AppBar across all main tabs.
- [ ] **Dashboard (Updated):** Build the new "Insight Home" using the reference structures.
- [ ] **Catalog (Updated):** Refine the `ProductsScreen` to match the "Atmospheric" list style.
- [ ] **Route Tracker:** Implement the `ActiveRouteScreen` for delivery tracking.
- [ ] **Delivery Details:** Implement the detail view for individual customer drops.

---

## 4. Engineering Constraints
- **State Management:** Use GetX for metrics and navigation.
- **Data Source:** Live Firestore streams for all counts (Subscriptions, Active Drops).
- **Assets:** Use Network images (from references) as placeholders until real vendor assets are uploaded.
