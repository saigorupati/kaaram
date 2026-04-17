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

## Setup checklist

The whole schema is defined in [`scripts/cloudkit-schema.ckdb`](../scripts/cloudkit-schema.ckdb) and imported with one command. You do NOT need to click 18 "Add Field" buttons in the web UI.

### One-time prerequisites

1. **Paid Apple Developer account** and signed in to Xcode (Xcode → Settings → Accounts).
2. **CloudKit container exists.** Open `kaaram.xcodeproj`, select the `kaaram` target → Signing & Capabilities → confirm iCloud/CloudKit container `iCloud.com.saigorupati.kaaram` is listed (Xcode auto-creates it on the server). If there's a warning triangle, click refresh.
3. **CloudKit Management Token.**
   - Visit https://icloud.developer.apple.com/dashboard/
   - Top-right **Team** menu → **Manage Tokens**
   - **Create Token** → role: **Admin** → copy the token
   - On your Mac:
     ```
     xcrun cktool save-token --type management
     ```
     Paste the token when prompted.

### Import the schema

```
./scripts/import-cloudkit-schema.sh
```

That's it. The script validates, then imports, then prints a URL to verify in the Console. It's idempotent — safe to re-run after schema edits.

### Seed a test recipe

Option A — CloudKit Console (browser):
- Data → Development → Public Database → Recipe → New Record → set `slug = test`, `nameEN = Test`, `isPublished = 1` → Save.

Option B — `cktool`:
```
xcrun cktool create-record \
  --team-id TUA96GSK9L \
  --container-id iCloud.com.saigorupati.kaaram \
  --database-type PUBLIC \
  --environment DEVELOPMENT \
  --record-type Recipe \
  --fields nameEN=Test --fields slug=test --fields isPublished=1
```

### Deploy to Production (Phase 7 only — don't do this yet)

```
./scripts/import-cloudkit-schema.sh PRODUCTION
```

Or click **Deploy Schema to Production** in the Console. Forgetting this step = empty app in prod.

## Recipe authoring workflow

- Open CloudKit Console → Development → Public Database → `Recipe` → **New Record**.
- Fill fields. For images, prepare 1200×900 (hero) and 400×300 (thumbnail) JPEGs locally, then upload via the Asset fields.
- Set `isPublished = 1` when ready to be visible in the app.
- Use `schemaVersion = 1` for now; bump when the record shape changes.
