# Fastlane Setup

One-time setup so `fastlane beta` ships a TestFlight build from the terminal.

```bash
cd /Users/saigorupati/Projects/kaaram
fastlane beta
```

What that does:
1. Fetches the latest TestFlight build number and bumps to `N + 1`.
2. Archives a Release build of the `kaaram` scheme.
3. Uploads the IPA to App Store Connect.
4. Apple emails you when processing completes.

---

## Prereqs

```bash
brew install fastlane
```

Already done — `fastlane --version` should print `2.233.0` or newer.

## 1. Generate an App Store Connect API key (5 min, one-time)

Apple's API keys replace app-specific passwords for CI/CLI auth.

1. Sign in at https://appstoreconnect.apple.com
2. Left sidebar: **Users and Access** → top tabs: **Integrations**
3. Under **App Store Connect API**, select the **Team Keys** tab → click the blue **+** button
4. Name: `Kaaram Fastlane` · Access: **App Manager** (Developer is not enough for TestFlight uploads)
5. Click **Generate** → Apple shows a one-time download for the `.p8` key file
6. **Download** the `AuthKey_XXXXXXXXXX.p8` file — you can only download it once
7. Note down the two IDs shown on the same page:
   - **Key ID** (e.g. `ABCD123456`)
   - **Issuer ID** (the team-level UUID at the top of the Keys page, e.g. `69a6de7e-...`)

## 2. Stash the key + IDs in `.env`

Fastlane reads env vars from `fastlane/.env` (gitignored).

```bash
mkdir -p ~/.fastlane
mv ~/Downloads/AuthKey_ABCD123456.p8 ~/.fastlane/

cat > fastlane/.env <<EOF
APP_STORE_CONNECT_KEY_ID=ABCD123456
APP_STORE_CONNECT_ISSUER_ID=69a6de7e-xxxx-xxxx-xxxx-xxxxxxxxxxxx
APP_STORE_CONNECT_KEY_CONTENT=$(cat ~/.fastlane/AuthKey_ABCD123456.p8)
EOF
```

(The `.env` file is in `.gitignore`; don't commit it.)

## 3. Confirm config

```bash
fastlane sanity
```

Should print: `Fastlane loaded. Project: kaaram.xcodeproj, scheme: kaaram`.

## 4. Ship a build

```bash
fastlane beta
```

First run takes 5–10 min (archive + upload). After that, about 4–6 min per build. When it finishes:
- Build auto-appears in App Store Connect → TestFlight → iOS builds with **Processing** status
- Apple emails you when processing is done (~10 min)
- Answer export compliance the first time (once per version, not per build) — Standard HTTPS exemption
- Build becomes installable by anyone in your Internal Testing group

---

## Troubleshooting

**"No profiles for 'com.saigorupati.kaaram' were found"** — Open Xcode once, let it auto-manage signing (Signing & Capabilities tab, Automatic checked). That creates the profiles in your keychain; Fastlane then reuses them.

**"ensure_git_status_clean - uncommitted changes"** — Fastlane's `before_all` block refuses to build if the working tree is dirty (prevents you from shipping untracked local hacks). Commit or stash first.

**"Unable to upload build — The bundle version must be higher"** — shouldn't happen; the lane pulls the latest TF build and bumps by 1. If it does, Apple's API was momentarily stale; re-run.

**Rotating the key** — repeat step 1, regenerate `fastlane/.env` with new values, delete the old key from App Store Connect.

---

## Comparison to Expo / EAS

| | Expo (EAS) | Fastlane (this setup) |
|---|---|---|
| One command to ship | `eas submit -p ios` | `fastlane beta` |
| Build happens | In Expo's cloud | Locally on your Mac |
| Auth token | `expo login` | ASC API key via env vars |
| Build number bumping | Automatic | Automatic (Fastfile does it) |
| Hands-off TestFlight upload | ✅ | ✅ |

Local builds mean first archive is slower than EAS (no Apple Silicon farm warm cache), but you're not waiting in a build queue and can iterate without a network round-trip.
