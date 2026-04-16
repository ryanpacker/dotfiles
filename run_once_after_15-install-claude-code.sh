#!/bin/bash
set -e

# Claude Code is installed via Anthropic's native installer rather than the
# Homebrew cask. The native installer auto-updates in the background, while
# the brew cask lags behind Anthropic's npm releases by hours-to-days,
# producing nagging "update available" notifications brew can't satisfy.
# See: https://code.claude.com/docs/en/setup
#
# This script also migrates away from the legacy Homebrew install if found,
# so machines that previously had `cask "claude-code"` get cleaned up.

# Migrate away from the legacy Homebrew cask if present
if command -v brew &>/dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if brew list --cask claude-code &>/dev/null; then
        echo "Removing legacy Homebrew claude-code cask..."
        brew uninstall --cask claude-code
    fi
fi

# Native installer is idempotent and self-updates after first install,
# so once `claude` is on PATH we never need to run the installer again.
if command -v claude >/dev/null 2>&1; then
    exit 0
fi

echo "Installing Claude Code via native installer..."
curl -fsSL https://claude.ai/install.sh | bash
