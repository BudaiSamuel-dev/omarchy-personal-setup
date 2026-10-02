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
   add`.
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

## My own plugins

Two of the plugins in `MANIFEST.plugins` are mine, and this repo carries the
config that wires them in:

- **[Gaming Mode](https://github.com/BudaiSamuel-dev/omarchy-gaming-mode)**:
  a bar icon that detects a running game and keeps the screen awake, silences
  notifications and turns off animations while it runs. `SUPER+CTRL+SHIFT+G`
  toggles it by hand. Wiring: `hypr/gaming.lua` (compositor-level idle
  inhibit), `bin/omarchy-toggle-gaming-mode`, and the keybinding in
  `hypr/bindings.lua`.
- **[Monitor Workspaces](https://github.com/BudaiSamuel-dev/omarchy-monitor-workspaces)**:
  every monitor gets its own workspaces 1–0. `SUPER+N` goes to the primary
  (external) monitor's workspace N, `SUPER+RightAlt+N` to the laptop's, and
  adding `SHIFT` moves the active window there. Each screen's bar shows only
  its own workspaces. Wiring: the loader at the end of `hypr/hyprland.lua`,
  `lv3:ralt_switch` in `hypr/input.lua` (makes Right Alt usable as a
  modifier), and the widget's entry in `omarchy/shell.json`.

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

After `omarchy plugin add <url>` or `omarchy theme install <url>`, add a
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
