#!/bin/sh
# Perch installer — downloads the latest release DMG, verifies it, installs to /Applications.
# Usage: curl -fsSL https://raw.githubusercontent.com/azharbinanwar/perch-releases/main/install.sh | sh
set -e

REPO="azharbinanwar/perch-releases"
APP="/Applications/Perch.app"
BASE_URL="https://github.com/$REPO/releases/latest/download"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Downloading latest Perch..."
curl -fL --progress-bar "$BASE_URL/Perch.dmg" -o "$TMP/Perch.dmg"

echo "Verifying checksum..."
curl -fsSL "$BASE_URL/Perch.dmg.sha256" -o "$TMP/Perch.dmg.sha256"
(cd "$TMP" && shasum -a 256 -c Perch.dmg.sha256 >/dev/null) || {
  echo "Error: checksum verification failed — download may be corrupted. Aborting." >&2
  exit 1
}
echo "Checksum OK."

echo "Mounting DMG..."
MOUNT=$(hdiutil attach "$TMP/Perch.dmg" -nobrowse -noautoopen | grep -o '/Volumes/.*' | tail -1)

if [ ! -d "$MOUNT/Perch.app" ]; then
  hdiutil detach "$MOUNT" -quiet || true
  echo "Error: Perch.app not found in DMG." >&2
  exit 1
fi

# Quit running instance if any
osascript -e 'tell application "Perch" to quit' >/dev/null 2>&1 || true

echo "Installing to /Applications..."
rm -rf "$APP"
cp -R "$MOUNT/Perch.app" /Applications/
hdiutil detach "$MOUNT" -quiet

# Remove quarantine (app is ad-hoc signed, not notarized)
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

echo "✅ Perch installed."
open "$APP"
