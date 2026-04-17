# Kaaram — CloudKit Schema

Container: `iCloud.com.saigorupati.kaaram`

This document is the source of truth for the CloudKit schema. Mirror it in CloudKit Console (Development environment first, then deploy to Production before the App Store release).

---

## Record Type: `Recipe` (Public Database)

| Field              | Type                | Indexed              | Notes                                                        |
|--------------------|---------------------|----------------------|--------------------------------------------------------------|
| `nameEN`           | String              | Queryable, Searchable | English display name, e.g. "Pappu"                          |
| `nameTE`           | String              | —                    | Telugu script, e.g. "పప్పు"                                  |
| `nameRomanized`    | String              | Queryable, Searchable | ASCII for search, e.g. "pappu"                              |
| `slug`             | String              | Queryable (unique)    | URL-safe id, e.g. "pappu"                                   |
| `summary`          | String              | —                    | 1–2 sentence description                                     |
| `category`         | String              | Queryable             | one of: breakfast, curry, pickle, sweet, festive, tiffin, rice, chutney, snack |
| `region`           | String              | Queryable             | one of: andhra, telangana, south-indian                     |
| `difficulty`       | Int64 (1–3)         | Sortable              | 1 = easy, 3 = involved                                      |
| `totalMinutes`     | Int64               | Sortable              | Total cook + prep                                           |
| `servings`         | Int64               | —                    |                                                              |
| `heroImage`        | Asset (CKAsset)     | —                    | 1200×900 JPEG, < 500 KB                                     |
| `thumbnailImage`   | Asset (CKAsset)     | —                    | 400×300 JPEG, < 80 KB                                       |
| `ingredientsJSON`  | String              | —                    | JSON array, see schema below                                |
| `stepsJSON`        | String              | —                    | JSON array, see schema below                                |
| `tags`             | List of String      | Queryable (list)      | e.g. ["vegetarian", "glutenfree", "kidfriendly"]            |
| `isPublished`      | Int64 (0/1)         | Queryable             | Soft publish flag                                            |
| `publishedAt`      | Date/Time           | Sortable              | Drives "New" sort                                            |
| `schemaVersion`    | Int64               | —                    | Start at 1                                                   |

### `ingredientsJSON` shape

```json
[
  { "qty": "1", "unit": "cup", "item": "toor dal", "notes": null },
  { "qty": "2", "unit": "tbsp", "item": "ghee", "notes": "for tempering" }
]
```

### `stepsJSON` shape

```json
[
  { "text": "Rinse dal and pressure cook with water for 4 whistles.", "durationSec": 900 },
  { "text": "Heat ghee, add mustard seeds and curry leaves.", "durationSec": 120 }
]
```

---

## Record Type: `FavoriteRecipe` (Private Database, device-synced)

Stored via SwiftData with `ModelConfiguration(cloudKitDatabase: .private)`. Not authored in Console.

| Field         | Type       | Notes                              |
|---------------|------------|------------------------------------|
| `recipeSlug`  | String     | FK to `Recipe.slug`                |
| `favoritedAt` | Date       |                                    |

## Record Type: `RecipeNote` (Private Database, device-synced)

| Field         | Type       | Notes                              |
|---------------|------------|------------------------------------|
| `recipeSlug`  | String     | FK to `Recipe.slug`                |
| `body`        | String     | User's own notes                   |
| `updatedAt`   | Date       |                                    |

---

## Setup checklist (manual, one-time)

1. Enable CloudKit capability in Xcode for the `kaaram` target (already set in `kaaram.entitlements`).
2. In [CloudKit Console](https://icloud.developer.apple.com/dashboard/), open container `iCloud.com.saigorupati.kaaram`.
3. Under **Schema → Record Types**, create `Recipe` with the fields above. Mark indexes exactly as the table specifies. **This is the #1 gotcha** — unindexed fields silently return no results in queries.
4. In **Security Roles**, ensure `_world` has **Read** on `Recipe`. (No write for the public — only you, as the container owner, write via Console.)
5. Add a Queryable system index on `recordName` for `Recipe` (needed for `CKQuery` with `NSPredicate(value: true)`).
6. Enter ~5 seed recipes in Development environment.
7. **Before App Store submission**: click **Deploy Schema Changes** to push to Production. Forgetting this = empty app in prod.

## Recipe authoring workflow

- Open CloudKit Console → Development → Public Database → `Recipe` → **New Record**.
- Fill fields. For images, prepare 1200×900 (hero) and 400×300 (thumbnail) JPEGs locally, then upload via the Asset fields.
- Set `isPublished = 1` when ready to be visible in the app.
- Use `schemaVersion = 1` for now; bump when the record shape changes.
