# Mac Setup Manifest

> This file describes **what** should be set up on a new Mac. Claude Code reads
> this file and implements each item using the appropriate chezmoi mechanism
> (Brewfile entry, defaults write, template, run script, or interactive prompt).
>
> Add items in plain language. Run Claude Code against this repo to translate
> new entries into implementation.

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

- Computer hostname
- Work vs personal machine
- Full name and email (for git)
- NAS IP and SSH username (personal only)
- Forgejo domain (personal only)
- Optional: install 3D printing tools (personal only)

## Dotfiles

| File | Description |
|------|-------------|
| `.zshenv` | Sets ZDOTDIR=$HOME/.zsh (nothing else) |
| `.zsh/.zshrc` | Prompt, PATH, tool initialization (Homebrew, nvm, pyenv, uv, bun) |
| `.zsh/.zsh_aliases` | Shell aliases |
| `.gitconfig` | User identity, LFS, credential helpers (GitHub, Forgejo) |
| `.config/ghostty/config` | Terminal: Catppuccin Mocha, JetBrains Mono, splits, keybinds |

## Apps — All Machines

- Google Chrome
- 1Password
- Visual Studio Code
- Cursor
- Zoom
- Ghostty
- Dropbox
- Google Drive
- Microsoft Office
- Adobe Creative Cloud

## Apps — Personal Only

- OBS (install only; scenes/profiles configured separately)
- Google Earth Pro

## Apps — Personal, Optional (3D Printing)

- Prusa Slicer
- Autodesk Fusion

## CLI Tools

- chezmoi
- gh (GitHub CLI)
- git
- Node.js / npm
- Speedtest CLI
- Claude Code (installed via Homebrew cask `claude-code`; provides the `claude` binary)
- Xcode Command Line Tools (via run_once script, not Brewfile)

## Dev Stack

- pyenv (Python version management)
- PHP
- PostgreSQL 16
- RabbitMQ
- Symfony CLI

## Fonts

- Source Code Pro
- JetBrains Mono

## macOS Settings

- Trackpad: tap to click enabled
- Scroll direction: traditional (not natural)
- Dock: autohide, tile size 48, magnification on, hide recent apps
- Hot corners: top-left = screen saver, bottom-right = quick note
- Finder: show path bar, show status bar, show all file extensions
- Computer hostname: set from prompted value

## Deferred / TODO

- [ ] Google Earth iCloud sync (need to determine iCloud target path)
- [ ] Display scaling preference
- [ ] Lock screen timeout and message
- [ ] Work-only tools section (add as needed)
- [ ] OBS scenes and profiles for church broadcasts
- [ ] Dock icon arrangement automation (dockutil)

## Manual Steps (Can't Automate)

These are presented as a checklist after `chezmoi apply` completes:

- Sign in to Apple ID
- Set up Apple Pay
- Enable iCloud Messages sync
- Sign in to 1Password, Chrome, Creative Cloud
- Sign in to Cursor (OAuth — can't be automated)
- Run `claude` and sign in (OAuth — can't be automated)
- Run `gh auth login`
- Set up Canon printers with accounting codes
- Install Canon Print & Layout
- Connect to NAS
- Arrange dock icons
- Configure widgets
- Set display scaling
- Set lock screen timeout
