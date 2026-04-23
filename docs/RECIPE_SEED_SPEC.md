
# Recipe Seed Data Spec

Reference for building an automation service that seeds recipes into the Kaaram CloudKit database.

**Target**: CloudKit Public DB, record type `Recipe`, container `iCloud.com.saigorupati.kaaram` (team `TUA96GSK9L`).

---

## File shape

One JSON file per recipe, named `<slug>.json`, dropped into [`scripts/seed-recipes/`](../scripts/seed-recipes/). Each file is a flat object where every field is tagged with its CloudKit type — this is the format `xcrun cktool create-record --fields-file` expects.

```json
{
  "nameEN":          { "type": "stringType",     "value": "Gongura Mamsam" },
  "nameTE":          { "type": "stringType",     "value": "గోంగూర మాంసం" },
  "nameRomanized":   { "type": "stringType",     "value": "gongura mamsam" },
  "slug":            { "type": "stringType",     "value": "gongura-mamsam" },
  "summary":         { "type": "stringType",     "value": "Tender mutton braised with sour gongura leaves, dried red chillies, and curry leaf." },
  "category":        { "type": "stringType",     "value": "curry" },
  "region":          { "type": "stringType",     "value": "andhra" },
  "difficulty":      { "type": "int64Type",      "value": 3 },
  "totalMinutes":    { "type": "int64Type",      "value": 80 },
  "servings":        { "type": "int64Type",      "value": 4 },
  "ingredientsJSON": { "type": "stringType",     "value": "[{...}, {...}]" },
  "stepsJSON":       { "type": "stringType",     "value": "[{...}, {...}]" },
  "tags":            { "type": "stringListType", "value": ["andhra", "non-veg", "weekend"] },
  "isPublished":     { "type": "int64Type",      "value": 1 },
  "schemaVersion":   { "type": "int64Type",      "value": 1 }
}
```

---

## Field reference

| Field             | CK type          | Required | Notes |
|-------------------|------------------|----------|-------|
| `nameEN`          | `stringType`     | yes      | English display name |
| `nameTE`          | `stringType`     | no       | Telugu script; `""` if unknown |
| `nameRomanized`   | `stringType`     | yes      | ASCII lowercase; drives search |
| `slug`            | `stringType`     | yes      | URL-safe id, unique, kebab-case (`gongura-mamsam`) |
| `summary`         | `stringType`     | no       | 1–2 sentences |
| `category`        | `stringType`     | yes      | enum: `breakfast` · `curry` · `pickle` · `sweet` · `festive` · `tiffin` · `rice` · `chutney` · `snack` · `other` |
| `region`          | `stringType`     | yes      | enum: `andhra` · `telangana` · `south-indian` · `north-indian` · `other` |
| `difficulty`      | `int64Type`      | yes      | `1` (easy), `2` (medium), `3` (involved) |
| `totalMinutes`    | `int64Type`      | yes      | prep + cook total |
| `servings`        | `int64Type`      | yes      | integer |
| `ingredientsJSON` | `stringType`     | yes      | stringified JSON array — see below |
| `stepsJSON`       | `stringType`     | yes      | stringified JSON array — see below |
| `tags`            | `stringListType` | no       | lowercase hyphen-free where possible (`vegetarian`, `glutenfree`, `kidfriendly`, `festive`, `spicy`) |
| `isPublished`     | `int64Type`      | yes      | `1` to ship, `0` to hide |
| `schemaVersion`   | `int64Type`      | yes      | `1` — bump when you change the record shape |
| `publishedAt`     | `timestampType`  | no       | ms since epoch; `cktool` sets `___createTime` automatically, but for stable sort order across re-seeds set this explicitly |
| `heroImage`       | `assetType`      | no       | 1200×900 JPEG, <500 KB. Supplied via `--assets-dir` on cktool, not inline |
| `thumbnailImage`  | `assetType`      | no       | 400×300 JPEG, <80 KB |

---

## `ingredientsJSON` inner shape

Stringified array of objects. Each object matches `Recipe.Ingredient` in the Swift model:

```json
[
  { "section": "For blanching", "qty": "400-500", "unit": "g",     "item": "spinach",              "notes": null },
  { "section": "For blanching", "qty": "1",       "unit": "liter", "item": "water",                "notes": null },
  { "section": "For the paste", "qty": "3",       "unit": null,    "item": "cloves",               "notes": null },
  { "section": "For the curry", "qty": "1",       "unit": "tbsp",  "item": "fresh cream",          "notes": "optional" }
]
```

- `section` groups ingredients in the UI under a red sub-header ("For the paste"). `null` = no group header; consecutive ingredients with the same `section` value merge into one group.
- `qty` is a **string** so it can be `"1/2"`, `"400-500"`, `"1 to 1 1/4"`.
- `unit` is `null` for countable items (e.g. `"3 cloves"`).
- `notes` is `null` or a short qualifier (`"optional"`, `"crushed"`, `"more if needed"`).

---

## `stepsJSON` inner shape

Stringified array of objects matching `Recipe.Step`:

```json
[
  { "text": "Boil 1 liter water. Add spinach and cook 2–3 minutes.",        "durationSec": 300 },
  { "text": "Blend cooked mixture with spinach into a smooth paste.",       "durationSec": null },
  { "text": "Heat oil and butter. Add cumin and curry leaves.",             "durationSec": 120 }
]
```

- `durationSec` is optional. When present, Cooking Mode shows an inline timer chip on that step and the timer card counts down from that value.

---

## Gotchas your service should handle

1. **Escape the inner JSON.** `ingredientsJSON` / `stepsJSON` are `stringType` fields, so the array must be serialized and embedded as a string (quotes escaped). Don't try to send them as nested objects — CloudKit will reject.
2. **Slug uniqueness.** The `cktool` CLI does **not** upsert. Re-running the seed script on an existing slug creates a duplicate row. If your service re-seeds, first `cktool query-records --filter "slug=<slug>"` and `delete-record` on the hit before `create-record`.
3. **Enums are validated client-side only.** The app maps unknown `category`/`region` values to `.other`, so invalid values won't crash — they just land in "Other". Still, stick to the allowed list above.
4. **Image assets.** `heroImage` / `thumbnailImage` can't be inlined in the JSON. `cktool` takes them via `--assets-dir <dir>` where filenames match `<recordName>.<fieldName>.<ext>` (e.g. `ABC123.heroImage.jpg`). Easier alternatives: upload images in a second pass, or extend the schema with a `heroURL: String` field pointing at a CDN.
5. **Schema deploy to Production.** Dev-env records never show on App Store builds. Run `./scripts/import-cloudkit-schema.sh PRODUCTION` (or click Deploy in the CloudKit Console) before any production seed.
6. **Token scope.** `xcrun cktool save-token --type management` must be done on whatever machine runs the service. For CI, use the `CLOUDKIT_MANAGEMENT_TOKEN` env var and pass with `--token`.
7. **Rate.** No documented `cktool` rate limit, but batches >100 recipes have been flaky — sleep ~200 ms between calls and retry on transient failures (exit code ≠ 0 with a "please try again" message is safely retryable).

---

## Minimal create command (what the service invokes)

```bash
xcrun cktool create-record \
  --team-id TUA96GSK9L \
  --container-id iCloud.com.saigorupati.kaaram \
  --database-type PUBLIC \
  --environment DEVELOPMENT \
  --record-type Recipe \
  --fields-file path/to/<slug>.json
```

Swap `--environment PRODUCTION` to promote.

---

## Recommended service architecture

1. **Source of truth**: keep recipes in a human-readable format (Markdown with YAML front-matter, or a Google Sheet exported to CSV). Your service transforms → the CloudKit JSON shape above.
2. **Idempotent seed**: for each input record, `query` by slug → if exists, `delete` then `create`; if absent, `create`. Log each action.
3. **Validate before writing**: fail fast if `category`/`region` enum is off, if `slug` isn't URL-safe, if `ingredientsJSON`/`stepsJSON` don't parse, or if required fields are missing.
4. **Dry-run mode**: emit the resulting JSON files to a staging dir without calling `cktool` — lets you inspect diffs in git before committing a batch.
5. **Environment split**: default to `DEVELOPMENT`, require an explicit flag (`--prod` or env var) to write to `PRODUCTION`.

---

## Reference

- Full schema doc: [docs/CLOUDKIT_SCHEMA.md](CLOUDKIT_SCHEMA.md)
- Canonical seed sample: [scripts/seed-recipes/palak-paneer.json](../scripts/seed-recipes/palak-paneer.json)
- Schema DDL (importable via `import-cloudkit-schema.sh`): [scripts/cloudkit-schema.ckdb](../scripts/cloudkit-schema.ckdb)
- Swift model the fields map to: [kaaram/Models/Recipe.swift](../kaaram/Models/Recipe.swift)
- Existing seed script (good starting point for your service): [scripts/seed-recipes.sh](../scripts/seed-recipes.sh)
