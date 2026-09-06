# Omarchy Personal Setup

This is my personal [Omarchy](https://omarchy.org/) dotfiles repo: Hyprland
config, terminal configs, Neovim, and the shell plugins/themes I've installed
on top of a stock Omarchy install. Everything here is symlinked into
`~/.config` on my machine, so editing a config normally edits the file in
this repo — there's no separate export step, just `git commit` when I want a
snapshot. Cloning this repo onto a fresh Omarchy install and running
`install.sh` restores the whole setup, plugins and themes included.

## Install guide

On a fresh Omarchy install:

```bash
git clone https://github.com/BudaiSamuel-dev/omarchy-personal-setup.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` will:
1. Symlink every tracked config file into place under `~/.config` (backing
   up anything already there instead of overwriting it).
2. Re-clone every plugin listed in `MANIFEST.plugins` via `omarchy plugin
   clone`.
3. Re-clone every theme listed in `MANIFEST.themes` via `omarchy theme
   install`.

Then apply the changes:

```bash
omarchy restart shell
omarchy restart terminal
hyprctl reload
```

The script is idempotent — re-running it later (e.g. after adding a new
plugin/theme to the manifests) only fills in what's missing.

## What's tracked

- Hyprland config (`hypr/`)
- Terminal configs: Alacritty, foot, kitty, ghostty
- `btop`, `starship`, `git` config
- Neovim (`nvim/`, LazyVim-based)
- Omarchy shell/branding/hooks/menu overlays (`omarchy/`)
- `MANIFEST.plugins` / `MANIFEST.themes` — git URLs for installed Omarchy
  shell plugins and themes (each of those is its own upstream repo, so they
  aren't vendored here — just re-cloned on install)

Not tracked: `~/.local/state/omarchy` (runtime state), `~/.cache/omarchy`
(regenerable caches), and anything under `~/.config/omarchy/plugins` or
`~/.config/omarchy/themes` directly (see MANIFEST files instead).

## How it works

Each tracked file lives in this repo and is symlinked into place in
`~/.config/...`. Editing the file at its normal location edits the file in
this repo directly — there's no separate "sync" step. To snapshot a change:

```bash
cd ~/dotfiles
git add -A
git commit -m "describe the change"
git push
```

## Adding a new plugin or theme later

After `omarchy plugin clone <url>` or `omarchy theme install <url>`, add a
line to `MANIFEST.plugins` or `MANIFEST.themes`:

```
<id-or-slug> <git-url>
```

Commit it. On another machine, re-running `install.sh` will clone anything
listed that isn't already present.

## Tracking a new config file later

```bash
~/dotfiles/bin/dotfiles-add ~/.config/some-app/config.toml
```

This moves the file into the repo, symlinks it back, and prints the line to
add to `install.sh`'s `FILES` array so future installs pick it up.
