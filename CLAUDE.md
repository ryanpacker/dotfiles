# CLAUDE.md

Guidance for Claude Code working in this repo.

## What this repo is

A chezmoi source directory that bootstraps a fresh Mac end-to-end from
`ryanpacker/dotfiles`. It installs CLI tools, GUI apps, fonts, and dotfiles,
applies macOS `defaults`, and prints a remaining-manual-steps checklist.

The repo lives at `/Users/rpacker/.local/share/chezmoi` (chezmoi's default
source dir). Editing files here is the same as editing the source state —
there is no separate "working copy."

## The iteration loop

For any change to machine setup:

1. Update [SETUP.md](SETUP.md) so the human description stays accurate.
2. Update the chezmoi source files (Brewfile, scripts, templates, dotfiles) to
   implement it.
3. Preview: `chezmoi diff`.
4. Apply: `chezmoi apply` (or `chezmoi update` if you also want to pull).
5. Verify the change actually worked on this machine.
6. Commit after verification.

SETUP.md is the spec, not a changelog — keep it describing the current
intended state, not the diff.

## Commit timing

Commit **after** `chezmoi apply` succeeds and the change is verified. Rationale:
chezmoi source edits aren't "tested" until applied, and a bad commit on `main`
will pull-and-break other machines. Verifying first keeps broken states out of
history.

## How chezmoi interprets this directory

Source filename prefixes are behavior, not cosmetics. When adding files,
choose the prefix that matches the intent:

| Prefix / suffix | Meaning |
|---|---|
| `dot_foo` | Becomes `~/.foo` |
| `private_dot_foo` | Becomes `~/.foo` with `chmod 600` |
| `*.tmpl` | Rendered as a Go template with `.isWork`, `.fullName`, etc. |
| `run_once_<name>` | Executed once per machine (tracked by script hash) |
| `run_onchange_<name>` | Re-runs whenever the script's rendered content changes |
| `run_once_before_<name>` | Runs before applying dotfiles |
| `run_once_after_<name>` | Runs after applying dotfiles |
| Numeric prefix (`01`, `10`, `90`) | Ordering within the same class |

The `run_onchange_after_10-install-packages.sh.tmpl` trick: the first line
embeds `{{ include "dot_Brewfile.tmpl" | sha256sum }}` as a comment. Editing
the Brewfile changes that hash, which changes the script contents, which
makes chezmoi re-run `brew bundle`. Preserve this pattern when touching
either file.

## Execution order on a fresh Mac

1. `run_once_before_01-install-xcode-cli-tools.sh` — Xcode CLI (blocking wait)
2. `run_once_before_02-install-homebrew.sh` — Homebrew
3. Dotfiles applied (`.zshenv`, `.zsh/*`, `.gitconfig`, `.config/ghostty/config`, `.Brewfile`)
4. `run_once_20-configure-macos.sh.tmpl` — hostname, trackpad, dock, hot corners, Finder
5. `run_onchange_after_10-install-packages.sh.tmpl` — `brew bundle --global --no-upgrade`
6. `run_once_after_15-install-claude-code.sh` — Claude Code via native installer (not brew, to avoid version lag)
7. `run_once_after_90-manual-checklist.sh.tmpl` — prints remaining manual steps

Order matters: Homebrew must exist before the Brewfile runs; `.Brewfile` must
be in place before `brew bundle --global` reads it; macOS defaults run after
dotfiles to avoid conflicts.

## Template data

Populated by [.chezmoi.toml.tmpl](.chezmoi.toml.tmpl) on `chezmoi init`:

- `.computerName`, `.localHostName` — default to current `scutil` values
- `.isWork` — gates JAMF-managed apps (Chrome, Zoom, Office) off work machines
- `.fullName`, `.email` — git identity
- `.nasIP`, `.nasUser`, `.forgejoDomain` — personal only
- `.install3DPrinting` — personal only, gates Prusa Slicer + Fusion

When adding a conditional install, use the existing gates instead of
inventing new ones unless the category is genuinely new.

## Files ignored by chezmoi

`.chezmoiignore` excludes `SETUP.md`, `README.md`, `LICENSE` from the
destination — they're repo docs, not dotfiles. Add `CLAUDE.md` there if it's
ever added to git (it isn't applied to `$HOME`, but keeping the ignore list
explicit is clearer).

## Handy commands

```sh
chezmoi diff              # preview pending changes
chezmoi apply             # apply local source to $HOME
chezmoi update            # git pull --autostash --rebase, then apply
chezmoi status            # show what would change
chezmoi execute-template < file.tmpl   # test template rendering
chezmoi data              # dump the template variables
chezmoi managed           # list files chezmoi owns in $HOME
chezmoi doctor            # sanity-check the install
```

## Don'ts

- Don't edit files in `$HOME` directly — they'll be overwritten on next
  apply. Edit the source here instead.
- Don't remove the Brewfile hash comment from
  `run_onchange_after_10-install-packages.sh.tmpl`; it's load-bearing.
- Don't add `--upgrade` to `brew bundle` without discussion — the current
  `--no-upgrade` is intentional (it keeps reapplies fast and avoids surprise
  upgrades during setup).
- Don't commit machine-specific values from `.chezmoi.toml`; only the
  `.tmpl` is committed, the populated config is local-only.
