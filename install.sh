#!/bin/bash
# Omarchy dotfiles installer.
#
# Safe to re-run. On the machine these files were pulled OFF of, it migrates
# real config files into this repo and replaces them with symlinks. On a
# fresh machine, this repo already holds the canonical files, so it just
# symlinks them into place (backing up anything already there) and re-clones
# the plugins/themes listed in the MANIFEST.* files.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# repo-relative path -> home-relative path
FILES=(
  "hypr/bindings.lua:.config/hypr/bindings.lua"
  "hypr/monitors.lua:.config/hypr/monitors.lua"
  "hypr/looknfeel.lua:.config/hypr/looknfeel.lua"
  "hypr/hyprland.lua:.config/hypr/hyprland.lua"
  "hypr/input.lua:.config/hypr/input.lua"
  "hypr/autostart.lua:.config/hypr/autostart.lua"
  "hypr/hyprsunset.conf:.config/hypr/hyprsunset.conf"
  "hypr/xdph.conf:.config/hypr/xdph.conf"
  "hypr/.luarc.json:.config/hypr/.luarc.json"
  "alacritty/alacritty.toml:.config/alacritty/alacritty.toml"
  "foot/foot.ini:.config/foot/foot.ini"
  "kitty/kitty.conf:.config/kitty/kitty.conf"
  "ghostty/config:.config/ghostty/config"
  "btop/btop.conf:.config/btop/btop.conf"
  "starship.toml:.config/starship.toml"
  "git/config:.config/git/config"
  "nvim:.config/nvim"
  "omarchy/shell.json:.config/omarchy/shell.json"
  "omarchy/shell.toml:.config/omarchy/shell.toml"
  "omarchy/branding:.config/omarchy/branding"
  "omarchy/extensions/omarchy-menu.jsonc:.config/omarchy/extensions/omarchy-menu.jsonc"
  "omarchy/hooks/post-update.d/install-voxtype.hook:.config/omarchy/hooks/post-update.d/install-voxtype.hook"
  "omarchy/hooks/post-update.d/setup-agent.hook:.config/omarchy/hooks/post-update.d/setup-agent.hook"
  "omarchy/hooks/post-update.d/setup-fingerprint.hook:.config/omarchy/hooks/post-update.d/setup-fingerprint.hook"
  "omarchy/lock-designs/Poster.qml:.config/omarchy/lock-designs/Poster.qml"
  "omarchy/defaults/agent:.config/omarchy/defaults/agent"
)

link_one() {
  local repo_rel="$1" home_rel="$2"
  local repo_path="$DOTFILES_DIR/$repo_rel"
  local home_path="$HOME/$home_rel"

  mkdir -p "$(dirname "$repo_path")" "$(dirname "$home_path")"

  if [ -L "$home_path" ] && [ "$(readlink -f "$home_path")" = "$(readlink -f "$repo_path" 2>/dev/null)" ]; then
    echo "ok:       $home_rel"
    return
  fi

  if [ -e "$repo_path" ]; then
    # Repo already has the canonical copy (fresh-machine restore case).
    if [ -e "$home_path" ] || [ -L "$home_path" ]; then
      local backup="${home_path}.bak.$(date +%s)"
      mv "$home_path" "$backup"
      echo "backed up existing $home_rel -> $backup"
    fi
    ln -s "$repo_path" "$home_path"
    echo "linked:   $home_rel -> $repo_rel"
  elif [ -e "$home_path" ]; then
    # First-time migration on the source machine: adopt the file into the repo.
    mv "$home_path" "$repo_path"
    ln -s "$repo_path" "$home_path"
    echo "migrated: $home_rel -> $repo_rel"
  else
    echo "skip:     $home_rel (not found on repo or disk)"
  fi
}

echo "== Linking config files =="
for entry in "${FILES[@]}"; do
  link_one "${entry%%:*}" "${entry#*:}"
done

echo
echo "== Restoring plugins =="
if [ -f "$DOTFILES_DIR/MANIFEST.plugins" ]; then
  while read -r id url; do
    [ -z "${id:-}" ] && continue
    [[ "$id" == \#* ]] && continue
    if [ -d "$HOME/.config/omarchy/plugins/$id" ]; then
      echo "ok:       plugin $id already present"
    else
      echo "cloning:  plugin $id from $url"
      omarchy plugin clone "$url"
    fi
  done < "$DOTFILES_DIR/MANIFEST.plugins"
fi

echo
echo "== Restoring themes =="
if [ -f "$DOTFILES_DIR/MANIFEST.themes" ]; then
  while read -r slug url; do
    [ -z "${slug:-}" ] && continue
    [[ "$slug" == \#* ]] && continue
    if [ -d "$HOME/.config/omarchy/themes/$slug" ]; then
      echo "ok:       theme $slug already present"
    else
      echo "cloning:  theme $slug from $url"
      omarchy theme install "$url"
    fi
  done < "$DOTFILES_DIR/MANIFEST.themes"
fi

echo
echo "Done. Restart affected components if this is a fresh install:"
echo "  omarchy restart shell"
echo "  omarchy restart terminal"
echo "  hyprctl reload"
