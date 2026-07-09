#!/bin/sh
# Perch installer — downloads the latest release DMG and installs to /Applications.
# Usage: curl -fsSL https://raw.githubusercontent.com/azharbinanwar/perch-releases/main/install.sh | sh
set -e

REPO="azharbinanwar/perch-releases"
APP="/Applications/Perch.app"

echo "Fetching latest Perch release..."
DMG_URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -o '"browser_download_url": *"[^"]*\.dmg"' | head -1 | cut -d'"' -f4)

if [ -z "$DMG_URL" ]; then
  echo "Error: could not find a DMG in the latest release." >&2
  exit 1
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Downloading $(basename "$DMG_URL")..."
curl -fL --progress-bar "$DMG_URL" -o "$TMP/Perch.dmg"

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
