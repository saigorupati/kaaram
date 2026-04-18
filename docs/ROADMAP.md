# Kaaram — Roadmap (Initial → Production)

A living document. Update as phases finish or scope shifts.

---

## Locked-in stack

| Layer | Choice |
|---|---|
| UI | SwiftUI, iOS 17+ |
| Recipe backend | CloudKit **Public** Database |
| User data (favorites, notes) | SwiftData + CloudKit **Private** Database sync |
| Auth | Implicit via user's Apple ID (CloudKit) |
| Payments | StoreKit 2 (consumable tip jar) |
| Analytics/crashes | MetricKit + TelemetryDeck (optional) |

Bundle ID: `com.saigorupati.kaaram`
CloudKit container: `iCloud.com.saigorupati.kaaram`

---

## MVP (v1.0) feature set

1. Browse + search recipes
2. Step-by-step cooking mode
3. Favorites & personal notes

Language: English UI, each recipe shows name in **English / తెలుగు / romanized**.
Monetization: Free, with a tip jar (no feature gating).

---

## Phase 0 — Foundations ✅

- [x] Rename bundle ID to `com.saigorupati.kaaram`
- [x] Add CloudKit entitlement + container identifier
- [x] Accent color set (chili-red) in asset catalog
- [x] Design system: `Color+Kaaram`, `Font+Kaaram`, `Layout` (Spacing/Radius)
- [x] Reusable components: `Chip`, `BilingualName`, `RecipeCard`, `SectionHeader`
- [x] Placeholder home screen showcasing the design system
- [x] CloudKit schema documented (`docs/CLOUDKIT_SCHEMA.md`)
- [ ] **Manual**: create CloudKit container + `Recipe` record type in CloudKit Console
- [ ] **Manual**: reserve "Kaaram" in App Store Connect
- [ ] **Manual**: placeholder app icon (even a solid color works for now)

## Phase 1 — Core read path ✅

- [x] `Recipe` domain model + `RecipeRepository` protocol
- [x] `CloudKitRecipeRepository` with resilient per-record decoding
- [x] Home screen with loading / loaded / empty / error states + pull-to-refresh
- [x] Recipe detail: hero, bilingual name, meta chips, sectioned ingredients, numbered steps with timer badges, favorite + share
- [x] URLCache (50 MB RAM / 500 MB disk) for AsyncImage persistence
- [x] `CachedRecipe` SwiftData model + `RecipeCache` @ModelActor
- [x] `CachingRecipeRepository` network-first with cache fallback
- [x] Palak Paneer seeded via `./scripts/seed-recipes.sh`
- [ ] **Deferred**: real hero images, pagination (`CKQueryOperation`), seed more recipes

## Phase 2 — Search & filters ✅

- [x] TabView root (Home / Browse) with kaaram-spice tint
- [x] Browse tab with `.searchable` (EN + romanized + Telugu literal + summary + tags)
- [x] Region filter chips (selectable pills with haptic) below search
- [x] Category filter in toolbar menu (picker with 9 cases + "All")
- [x] Sort in toolbar menu: Newest / Quickest / Easiest
- [x] Clear-filters affordances (menu + empty state)
- [x] Recent searches persisted in UserDefaults; shown via `.searchSuggestions`; tap to reuse + clear-all
- [ ] **Deferred**: Tag filter (less urgent with the search box doing the job)

## Phase 3 — Step-by-step cooking mode ✅

- [x] Full-screen swipeable step view with large serif type
- [x] Segmented spice-colored progress bar (one capsule per step)
- [x] Per-step countdown timer with progress ring and start/pause/reset
- [x] Keep-awake while active (`isIdleTimerDisabled = true`, scoped)
- [x] Soft haptic on step advance; success haptic on timer completion
- [x] "You did it!" completion page with Done button + success haptic
- [ ] **Deferred**: Live Activity for timer, wall-clock math for true background accuracy

## Phase 4 — Favorites & notes ✅

- [x] `FavoriteRecipe` + `RecipeNote` SwiftData models with CloudKit private DB sync
- [x] Two-store ModelContainer (local cache + synced user data) with in-memory fallback
- [x] Heart button on Recipe detail wired to `@Query` + `modelContext`; symbol morph transition
- [x] Heart badges on Home cards (top-right overlay) and Browse rows (inline)
- [x] `favoriteSlugs` environment key fed by a single root-level `@Query`
- [x] Favorites tab with `favoritedAt`-ordered list; context-menu unfavorite
- [x] Extracted shared `RecipeRow` component (used by Browse + Favorites)
- [x] Note editor sheet: `TextEditor` with save/cancel, detents, keyboard delete; clearing text removes the note
- [x] Notes section on Recipe detail with pencil/plus state icon
- [x] Graceful degradation — on signed-out iCloud, SwiftData stays local

## Phase 5 — Localization & a11y polish

- [ ] String Catalog (`.xcstrings`) for all UI strings (English only at launch)
- [ ] User setting to toggle visibility of Telugu script / romanized names
- [ ] VoiceOver labels for every interactive element (chips, cards, buttons)
- [ ] Dynamic Type verified at all sizes up to AX5
- [ ] Dark mode parity pass
- [ ] Reduce Motion respected (disable shine/parallax if enabled)
- [ ] Right-to-left sanity check (even though Telugu is LTR)

## Phase 6 — Tip jar (monetization)

- [ ] StoreKit 2 setup with 3 consumables ($0.99 / $2.99 / $4.99)
- [ ] "Support Kaaram" screen with animated chili peppers on tap
- [ ] Receipt validation (StoreKit handles via `Transaction.currentEntitlements`)
- [ ] Thank-you moment after purchase (confetti / haptic / custom toast)
- [ ] StoreKit test configuration file for local testing

## Phase 7 — Pre-submission

- [ ] App icon: final 1024×1024 + all scale variants
- [ ] Launch screen / splash
- [ ] Screenshots: 6.9" / 6.5" / 13" iPad, all in both Light and Dark
- [ ] App Store listing:
  - [ ] Name & subtitle ("Kaaram" + "Telugu & South Indian Recipes")
  - [ ] Description (lead with the why)
  - [ ] Keywords (telugu, south indian, recipes, andhra, pulusu, pulihora…)
  - [ ] Promotional text (changeable without resubmit)
  - [ ] Support URL (GitHub Pages page is fine)
- [ ] Privacy policy hosted publicly
- [ ] **App Privacy** (nutrition label) filled in App Store Connect
- [ ] TestFlight internal build → external beta (10–20 testers)
- [ ] Fix critical bugs; confirm crash-free sessions > 99%
- [ ] **Deploy CloudKit schema to Production** (easy to forget!)

## Phase 8 — Launch

- [ ] Submit for review
- [ ] Announcement plan: social, r/IndianFood, r/TeluguPeople, Product Hunt, family WhatsApp
- [ ] Post-launch monitoring: MetricKit reports, App Store reviews, TelemetryDeck events
- [ ] Respond to reviews within 48h for the first 2 weeks

## v1.1 backlog (unordered; user-validate before building)

- Shopping list / ingredient checklist
- Servings scaler that rewrites quantities
- Meal planner (weekly)
- Video steps (CKAsset videos, or YouTube embeds)
- Telugu UI localization (full)
- Apple Watch complication / glance
- iPad-optimized layouts (two-column detail)
- Siri Shortcuts ("Start cooking Pappu")
- User-submitted recipes (huge scope — consider v2)

---

## Gotchas I should not forget

1. **CloudKit Public schema** must be deployed to Production before App Store release.
2. **Queryable/Sortable/Searchable** flags on fields — unindexed fields silently return empty queries.
3. **CKAsset size** — compress hero images to <500 KB, thumbnails to <80 KB.
4. **SwiftData + CloudKit**: all properties must be optional or have defaults.
5. **App name "Kaaram"** — verify availability in App Store Connect ASAP.
6. **Recipe copyright**: recipes aren't copyrightable but wording and photos are. Write my own or license.
7. **Age rating**: 4+ for a food app.
8. **Privacy nutrition label**: iCloud data stays with user; disclose any analytics.

---

## How to use this doc

- Check off items as they finish.
- Each phase ships in its own set of PRs; keep them reviewable (< 500 LoC where possible).
- If scope grows, update this file in the same PR.
- When an assumption breaks, add it to "Gotchas" above.
