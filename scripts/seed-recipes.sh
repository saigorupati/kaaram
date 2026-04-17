#!/usr/bin/env bash
#
# Seed recipes into the Kaaram CloudKit Public database.
# Reads every *.json file in scripts/seed-recipes/ and creates a record.
#
# Assumes: management token already saved via
#   xcrun cktool save-token --type management
#
# Usage:
#   ./scripts/seed-recipes.sh              # DEVELOPMENT environment (default)
#   ./scripts/seed-recipes.sh PRODUCTION   # deploy later

set -euo pipefail

TEAM_ID="TUA96GSK9L"
CONTAINER_ID="iCloud.com.saigorupati.kaaram"
ENVIRONMENT="${1:-DEVELOPMENT}"

SEED_DIR="$(cd "$(dirname "$0")" && pwd)/seed-recipes"

if [[ ! -d "$SEED_DIR" ]]; then
    echo "error: seed directory $SEED_DIR not found" >&2
    exit 1
fi

shopt -s nullglob
files=("$SEED_DIR"/*.json)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
    echo "No *.json seed files in $SEED_DIR"
    exit 0
fi

for file in "${files[@]}"; do
    echo "→ seeding $(basename "$file")..."
    xcrun cktool create-record \
        --team-id "$TEAM_ID" \
        --container-id "$CONTAINER_ID" \
        --database-type PUBLIC \
        --environment "$ENVIRONMENT" \
        --record-type Recipe \
        --fields-file "$file"
    echo
done

echo "✓ seeded ${#files[@]} recipe(s) into $ENVIRONMENT"
