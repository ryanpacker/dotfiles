#!/bin/bash
# Post-install automation. Runs after dotfiles and package installs, so
# dockutil, defaultbrowser, etc. are available.
set -u

echo "Running post-install tasks..."

# ---- Screenshots directory ----
# Create ~/Screenshots and point macOS screen-capture at it.
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"
echo "  ✓ Screenshots → ~/Screenshots"

# ---- Dock contents (dockutil) ----
# Pin Screenshots and Downloads as fan-view stacks sorted by most recent.
# Idempotent: dockutil --add replaces an existing entry with the same label.
if command -v dockutil >/dev/null 2>&1; then
    dockutil --no-restart --add "$HOME/Screenshots" --view fan --display stack --sort dateadded --allhomes >/dev/null 2>&1 || \
      dockutil --no-restart --add "$HOME/Screenshots" --view fan --display stack --sort dateadded >/dev/null 2>&1 || true
    dockutil --no-restart --add "$HOME/Downloads" --view fan --display stack --sort dateadded --allhomes >/dev/null 2>&1 || \
      dockutil --no-restart --add "$HOME/Downloads" --view fan --display stack --sort dateadded >/dev/null 2>&1 || true
    echo "  ✓ Dock stacks pinned (Screenshots, Downloads)"
else
    echo "  ⚠ dockutil not found — skipping dock pins"
fi

# ---- Google Earth settings sync via iCloud Drive ----
# Symlink ~/Library/Application Support/Google Earth to an iCloud Drive
# directory so config/signed-in accounts/bookmarks sync across Macs.
ICLOUD_ROOT="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
GE_ICLOUD="$ICLOUD_ROOT/AppSettings/Google Earth"
GE_LOCAL="$HOME/Library/Application Support/Google Earth"

if [ -d "$ICLOUD_ROOT" ]; then
    mkdir -p "$GE_ICLOUD"
    if [ -L "$GE_LOCAL" ]; then
        # Already a symlink — re-point it (handles moves).
        ln -sfn "$GE_ICLOUD" "$GE_LOCAL"
        echo "  ✓ Google Earth → iCloud (symlink refreshed)"
    elif [ -d "$GE_LOCAL" ]; then
        echo "  ⚠ Google Earth local dir already exists as a real directory — leaving alone to avoid clobbering settings."
        echo "    To migrate: quit Google Earth, move ~/Library/Application Support/Google Earth into $GE_ICLOUD, then re-run."
    else
        ln -sfn "$GE_ICLOUD" "$GE_LOCAL"
        echo "  ✓ Google Earth → iCloud (symlink created)"
    fi
else
    echo "  ⚠ iCloud Drive not available — skipping Google Earth symlink. Sign in to iCloud and re-run."
fi

# ---- Restart SystemUIServer so screenshot location + dock pick up changes ----
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "Post-install tasks done."
