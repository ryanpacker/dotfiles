#!/bin/sh
# Git credential helper for the Forgejo forge (forge.r9x.dev).
#
# The token is NEVER written to disk. On `get`, it is resolved in this order:
#   1. $FORGEJO_TOKEN  — a raw token injected for headless / unattended runs,
#      deliberately bypassing 1Password and the Touch ID gate (e.g. CI).
#   2. $FORGEJO_OP_REF — override which 1Password secret reference to read.
#   3. op://Private/Forgejo/token (default) — read live from 1Password; prompts
#      for Touch ID when 1Password is locked. This is the human-in-the-loop
#      gate for private-repo access.
#
# git's in-memory `cache` helper (see ~/.gitconfig) sits IN FRONT of this one,
# so the op fetch + Touch ID happen at most once per cache window, not per op.
# Rotation: update the 1Password item; the next op read returns the new value.
# Force-refresh a stale cache with:  git credential-cache exit

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

case "$1" in
  get)
    if [ -n "$FORGEJO_TOKEN" ]; then
      TOKEN="$FORGEJO_TOKEN"
    else
      TOKEN=$(op read "${FORGEJO_OP_REF:-op://Private/Forgejo/token}" 2>/dev/null)
    fi
    if [ -n "$TOKEN" ]; then
      echo "username=rpacker"
      echo "password=$TOKEN"
    fi
    ;;
esac
