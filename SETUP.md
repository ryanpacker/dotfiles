# Mac Setup Manifest

> This file describes **what** should be set up on a new Mac. Claude Code reads
> this file and implements each item using the appropriate chezmoi mechanism
> (Brewfile entry, defaults write, template, run script, or interactive prompt).
>
> Add items in plain language. Run Claude Code against this repo to translate
> new entries into implementation.

## Pre-Chezmoi Prerequisites (Do These First)

Complete these before running the bootstrap command. They can't be automated
because they require direct interaction with Apple's UI or services, and some
later steps depend on them.

- Change the login password (if the Mac shipped with a default or temporary one)
- Install any pending macOS software updates
- Add a fingerprint in System Settings → Touch ID & Password, then enable Touch ID
- Sign in to iCloud (required for any iCloud-synced settings and files below)
- Sign in to the Mac App Store (required so `mas` can install App Store apps later)

## Bootstrap (Fresh Mac)

Open Terminal.app and run:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ryanpacker/dotfiles
```

For subsequent updates on an already-configured machine:

```sh
chezmoi update
```

## Machine Configuration

Prompted during `chezmoi init` (stored locally, never committed):

- Computer hostname (friendly and local short name)
- Work vs personal machine
- BambooHR-managed machine (only asked on work machines; controls Jamf-aware behavior like skipping hostname configuration and the BHR opt-out app list)
- Full name and email (for git)
- NAS IP and SSH username
- Forgejo domain

## Dotfiles

| File | Description |
|------|-------------|
| `.zshenv` | Sets ZDOTDIR=$HOME/.zsh (nothing else) |
| `.zsh/.zshrc` | Prompt, PATH, tool initialization (Homebrew, nvm, pyenv, uv, bun) |
| `.zsh/.zsh_aliases` | Shell aliases |
| `.gitconfig` | User identity, LFS, credential helpers (GitHub, Forgejo) |
| `.config/ghostty/config` | Terminal: Catppuccin Mocha, JetBrains Mono, splits, keybinds |
| `Library/Application Support/Terminal/RDP Custom.terminal` | Terminal.app custom profile (committed to chezmoi so it works offline and stays version-controlled) |

## Apps — All Machines

Install on every machine via Homebrew cask (or the named mechanism), **except**
anything in the "Skipped on BambooHR Machines" opt-out list below.

- 1Password
- Adobe Creative Cloud (launcher only; specific Creative Cloud apps to install is deferred — see Deferred / Open Questions)
- Bambu Studio
- Canon Professional Print & Layout (manual — Canon installer, no Homebrew cask)
- Claude (desktop app, via Homebrew cask `claude`; auto-updates)
- Cursor
- Dropbox
- Autodesk Fusion
- Ghostty
- Google Chrome
- Google Drive
- Google Earth Pro
- Microsoft Office
- OBS (install only; scenes/profiles configured separately)
- Prusa Slicer
- Slack
- T3 Code
- Visual Studio Code
- Wispr Flow (voice-to-text dictation with AI auto-editing)
- Zoom

### Apps — Skipped on BambooHR Machines

On `isBHR` machines, JAMF deploys certain apps from the catalog. Installing them
again via Homebrew causes version drift and occasional permission conflicts, so
we skip these in the Brewfile via a `not .isBHR` gate.

**This list is a starting guess based on what was on the current BHR Mac —
edit it as you verify what JAMF actually installs for your role.**

- Google Chrome
- Google Drive
- Zoom
- Microsoft Office
- Slack

(1Password is **not** skipped — verified installed via Homebrew on the current
BHR Mac, not by JAMF.)

## Mac App Store Apps

Installed via the `mas` CLI. Requires completing the Mac App Store sign-in from
Pre-Chezmoi Prerequisites first.

- Speedtest by Ookla (desktop companion to the Ookla CLI)
- BlackMagic Disk Speed Test

## CLI Tools

- chezmoi
- gh (GitHub CLI)
- git
- Node.js / npm
- Ookla Speedtest CLI (official `speedtest` binary from the `teamookla/speedtest` tap; supersedes the community `speedtest-cli`)
- Claude Code (installed via Anthropic's native installer to `~/.local/bin/claude`; auto-updates in the background — Homebrew cask is intentionally avoided because it lags behind upstream releases)
- Xcode Command Line Tools (via run_once script, not Brewfile; sufficient for `make`, `gcc`, native Python extensions, and git. Full Xcode.app is intentionally not installed)
- `mas` (Mac App Store CLI; used for the App Store apps above)
- `dockutil` (for reproducible dock-contents automation)
- `defaultbrowser` (for setting Chrome as the default browser non-interactively)

## Dev Stack

Installed on all machines:

- pyenv (Python version management)
- PHP
- PostgreSQL 16
- RabbitMQ
- Symfony CLI

## Fonts

- Source Code Pro
- JetBrains Mono

## macOS Settings (Automated)

Applied by the macOS configuration script. All are `defaults write`-style
settings unless noted.

- Trackpad: tap to click enabled
- Mouse scroll direction: traditional (not natural)
- Finder: default view = column view, show path bar, show status bar, show all file extensions
- Remove any default desktop widgets (clears the per-user widget store so the desktop starts clean)
- Set Google Chrome as the default browser (via `defaultbrowser`; skipped on BambooHR machines where JAMF owns Chrome)
- Dock: autohide, tile size 48, magnification on, hide recent apps
- Hot corners: top-left = start screen saver, bottom-right = disable screen saver / stay awake (code 6)
- Screensaver: require password 2 seconds after screensaver/sleep begins
- Computer hostname: set from prompted value (skipped on BambooHR machines — Jamf enforces its own naming convention and overwrites any changes)

## Post-Install Automated Tasks

Run after apps are installed:

- **Google Earth settings sync**: symlink `~/Library/Application Support/Google Earth` to the matching iCloud Drive path so Google Earth configuration syncs across machines
- **Screenshots directory**: create `~/Screenshots` and configure macOS to save screenshots there (`defaults write com.apple.screencapture location`)
- **Dock contents** (via `dockutil`): pin `~/Screenshots` and `~/Downloads` as stack items with fan view and sort-by-most-recent; set overall dock icon arrangement
- **Install Source Code Pro font** (covered by the Fonts section above; listed here for the post-install mental model)

## Deferred / Open Questions

These are intentional TODOs — decide the specifics, then fold them in.

- Mouse tracking speed: pick a specific value
- Desktop wallpaper: decide on a source file (local, iCloud-synced, etc.)
- Per-display spaces preference (currently undecided)
- Laptop screen scaling: set to "more space"
- Display resolution presets for common monitor configurations (with and without external displays)
- Lock screen timeout and lock-screen message
- Creative Cloud — which specific Adobe apps to install (vs. just the launcher)
- Prusa Slicer and Bambu Studio settings sync across machines (iCloud? Git-tracked? Manual export/import?)
- OBS scenes and profiles sync across machines (including church-broadcast profile)
- NAS automount when on the home network (SSID-triggered LaunchAgent — needs testing before committing)
- Home printer setup automation, including the Canon Pro-4000

## Manual Steps (Can't Automate)

These are presented as a checklist after `chezmoi apply` completes.

- Set up Apple Pay
- Disable notifications for Notes.app (System Settings → Notifications → Notes → Allow Notifications off — modern macOS doesn't expose a reliable `defaults` key for this)
- Enable Unlock with Apple Watch (System Settings → Touch ID & Password — requires a paired Apple Watch and can't be scripted)
- Install 1Password browser extensions in Safari and Chrome, then sign in to 1Password
- Sign in to Google Chrome profiles and enable sync
- Sign in to Adobe Creative Cloud (and choose the specific apps to install)
- Sign in to Cursor (OAuth — can't be automated)
- Sign in to the Claude desktop app
- Run `claude` and sign in to Claude Code (OAuth — can't be automated)
- Run `gh auth login`
- Install Canon Professional Print & Layout (download from Canon)
- Set up home printers, including the Pro-4000
- Enable Dropbox and decide which folders sync automatically
- Connect to the NAS
- Set display scaling (System Settings → Displays)
- Set lock screen timeout
- Arrange additional dock icons beyond what the script pins
- Configure desktop widgets (if you want any after the script clears them)
