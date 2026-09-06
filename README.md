# dotfiles

Personal config, Omarchy shell plugins, and themes, kept in sync across
machines via symlinks + a small install script.

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

## Fresh machine setup

```bash
git clone git@github.com:<you>/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
omarchy restart shell
omarchy restart terminal
hyprctl reload
```

`install.sh` is idempotent — safe to re-run any time (e.g. after adding a
new plugin/theme to the manifests).

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
