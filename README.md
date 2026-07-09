# Perch

Keyboard & mouse power tools for macOS.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/azharbinanwar/perch-releases/main/install.sh | sh
```

Or download the DMG from [Releases](https://github.com/azharbinanwar/perch-releases/releases/latest), drag Perch to Applications, then run:

```sh
xattr -dr com.apple.quarantine /Applications/Perch.app
```

(The app is ad-hoc signed, not notarized — this clears the Gatekeeper quarantine flag.)

## Update

Re-run the install one-liner. It replaces the existing app with the latest release.
