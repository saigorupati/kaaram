#!/usr/bin/env bash
#
# Import the Kaaram CloudKit schema into the Development environment.
#
# Prereqs (one-time):
#
#   1. A paid Apple Developer account with the container
#      iCloud.com.saigorupati.kaaram created (Xcode does this automatically
#      when you enable iCloud capability on the kaaram target).
#
#   2. A CloudKit Management Token. Generate once:
#        - Visit https://icloud.developer.apple.com/dashboard/
#        - Pick any container → Team (top-right) → Manage Tokens
#        - "Create Token" → role: Admin → copy the token
#      Save it into the macOS keychain so cktool can reuse it:
#        xcrun cktool save-token --type management
#      (paste the token when prompted, press Enter)
#
# Usage:  ./scripts/import-cloudkit-schema.sh [environment]
#   environment defaults to DEVELOPMENT. Use PRODUCTION only at Phase 7.
#
# The team and container IDs are pinned below so this is idempotent.

set -euo pipefail

TEAM_ID="TUA96GSK9L"
CONTAINER_ID="iCloud.com.saigorupati.kaaram"
ENVIRONMENT="${1:-DEVELOPMENT}"

SCHEMA_FILE="$(cd "$(dirname "$0")" && pwd)/cloudkit-schema.ckdb"

if [[ ! -f "$SCHEMA_FILE" ]]; then
    echo "error: schema file not found at $SCHEMA_FILE" >&2
    exit 1
fi

echo "→ validating schema against $ENVIRONMENT..."
xcrun cktool validate-schema \
    --team-id "$TEAM_ID" \
    --container-id "$CONTAINER_ID" \
    --environment "$ENVIRONMENT" \
    --file "$SCHEMA_FILE"

echo
echo "→ importing schema into $ENVIRONMENT..."
xcrun cktool import-schema \
    --team-id "$TEAM_ID" \
    --container-id "$CONTAINER_ID" \
    --environment "$ENVIRONMENT" \
    --file "$SCHEMA_FILE"

echo
echo "✓ done. Verify in CloudKit Console:"
echo "  https://icloud.developer.apple.com/dashboard/database/teams/$TEAM_ID/containers/$CONTAINER_ID/environments/$ENVIRONMENT/schema/types"
