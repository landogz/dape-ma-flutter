#!/usr/bin/env bash
# Publish the release APK to a GitHub Release (Inside Scores–style).
# Requires: gh auth login
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PUBSPEC_VERSION="$(python3 - <<'PY'
from pathlib import Path
import re
text = Path("pubspec.yaml").read_text()
m = re.search(r"^version:\s*([0-9.]+)\+([0-9]+)\s*$", text, re.M)
if not m:
    raise SystemExit("Could not parse version from pubspec.yaml")
print(f"{m.group(1)}|{m.group(2)}")
PY
)"
VERSION="${PUBSPEC_VERSION%%|*}"
BUILD="${PUBSPEC_VERSION##*|}"
TAG="v${VERSION}+${BUILD}"
REPO="${GITHUB_REPO:-landogz/dape-ma-flutter}"
APK_SRC="${APK_SRC:-build/app/outputs/flutter-apk/app-release.apk}"
APK_NAME="dape-ma.apk"

need() {
  local path="$1"
  [[ -f "$path" ]] || { echo "Missing: $path — run flutter build apk --release first." >&2; exit 1; }
}

need "$APK_SRC"
command -v gh >/dev/null || { echo "gh CLI is required (gh auth login)." >&2; exit 1; }

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

cp "$APK_SRC" "$TMP/$APK_NAME"

NOTES="$(cat <<EOF
## DAPE-MA Android ${VERSION} (${BUILD})

| Asset | Notes |
| --- | --- |
| \`${APK_NAME}\` | Release APK |

Also mirrored at \`https://dapemade.ddb.gov.ph/download/dape-ma.apk\`.
In-app updates use the production \`/api/v1/app-update\` manifest.
EOF
)"

if ! gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
  echo "Creating GitHub release ${TAG}..."
  gh release create "$TAG" \
    --repo "$REPO" \
    --title "DAPE-MA ${VERSION} (${BUILD})" \
    --notes "$NOTES"
else
  echo "Release ${TAG} already exists — uploading assets"
fi

echo "Uploading ${APK_NAME}..."
gh release upload "$TAG" --repo "$REPO" --clobber "$TMP/$APK_NAME"

echo "Published ${TAG} → https://github.com/${REPO}/releases/tag/${TAG}"
echo "Download: https://github.com/${REPO}/releases/download/${TAG}/${APK_NAME}"
