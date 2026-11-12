#!/usr/bin/env bash
#
# The macOS look for Omarchy: SF Pro-style typography, a frosted glass menu
# bar, a Spotlight-style launcher, macOS-styled OSD, trackpad gestures,
# rounded translucent windows, and the Sequoia theme.
#
# Everything it touches is backed up first, so the change is easy to undo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

THEME_REPO="https://github.com/adhilroshan/omarchy-sequoia"
THEME_LIGHT_REPO="https://github.com/adhilroshan/omarchy-sequoia-light"

INSTALL_THEME=1
for arg in "$@"; do
  case "$arg" in
    --no-theme) INSTALL_THEME=0 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

say() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
note() { printf '    %s\n' "$1"; }

backup() {
  local path="$1"
  if [[ -e "$path" ]]; then
    cp -r "$path" "${path}.bak.${STAMP}"
    note "backed up ${path} -> ${path}.bak.${STAMP}"
  fi
}

if ! command -v omarchy >/dev/null 2>&1; then
  echo "This setup is for Omarchy (https://omarchy.org/). Install it first." >&2
  exit 1
fi

say "Fonts"
mkdir -p "$HOME/.local/share/fonts/inter" "$HOME/.local/share/fonts/nerd-symbols"
cp "$REPO_DIR"/fonts/inter/*.ttf "$HOME/.local/share/fonts/inter/"
cp "$REPO_DIR"/fonts/inter/LICENSE.txt "$HOME/.local/share/fonts/inter/"
cp "$REPO_DIR"/fonts/nerd-symbols/*.ttf "$HOME/.local/share/fonts/nerd-symbols/"
cp "$REPO_DIR"/fonts/nerd-symbols/LICENSE "$HOME/.local/share/fonts/nerd-symbols/"
fc-cache -f >/dev/null 2>&1 || true
note "Inter (SF Pro stand-in) and the Nerd Font symbols are installed"

say "Fontconfig"
mkdir -p "$HOME/.config/fontconfig/conf.d"
backup "$HOME/.config/fontconfig/fonts.conf"
cp "$REPO_DIR/config/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
cp "$REPO_DIR/config/fontconfig/conf.d/99-omarchy-inter-ui.conf" "$HOME/.config/fontconfig/conf.d/"
fc-cache -f >/dev/null 2>&1 || true
note "the shell renders in Inter; terminals keep their own monospace font"

say "Shell plugins"
mkdir -p "$HOME/.config/omarchy/plugins"
for plugin in artr.menu artr.workspaces artr.osd; do
  if [[ -d "$HOME/.config/omarchy/plugins/$plugin" ]]; then
    cp -r "$HOME/.config/omarchy/plugins/$plugin" "$HOME/.config/omarchy/plugins/.${plugin}.bak.${STAMP}"
    note "backed up plugins/$plugin"
  fi
  rm -rf "$HOME/.config/omarchy/plugins/$plugin"
  cp -r "$REPO_DIR/config/plugins/$plugin" "$HOME/.config/omarchy/plugins/$plugin"
done
note "Spotlight-style launcher, dot-style workspace strip, and macOS-styled OSD"

say "Hyprland look and feel"
mkdir -p "$HOME/.config/hypr"
backup "$HOME/.config/hypr/looknfeel.lua"
cp "$REPO_DIR/config/hypr/looknfeel.lua" "$HOME/.config/hypr/looknfeel.lua"
backup "$HOME/.config/hypr/input.lua"
cp "$REPO_DIR/config/hypr/input.lua" "$HOME/.config/hypr/input.lua"
note "rounded corners, hairline borders, translucent windows, blur, macOS-like animations"
note "trackpad gestures and input tuning (natural scroll, 3/4-finger gestures)"

say "Touchpad helper"
mkdir -p "$HOME/.local/bin"
backup "$HOME/.local/bin/touchpad-volume"
cp "$REPO_DIR/bin/touchpad-volume" "$HOME/.local/bin/touchpad-volume"
chmod +x "$HOME/.local/bin/touchpad-volume"
note "installed ~/.local/bin/touchpad-volume for 4-finger volume gesture"

say "Hyprland glass toggles"
TOGGLES_DIR="$HOME/.local/state/omarchy/toggles/hypr"
mkdir -p "$TOGGLES_DIR"
for toggle in bar-glassy.lua window-glassy.lua; do
  if [[ -f "/usr/share/omarchy/default/hypr/toggles/$toggle" ]]; then
    cp "/usr/share/omarchy/default/hypr/toggles/$toggle" "$TOGGLES_DIR/$toggle"
  fi
done
note "the menu bar and every shell surface blur what is behind them"

say "Shell configuration"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
if [[ -f "$SHELL_JSON" ]]; then
  backup "$SHELL_JSON"
  jq '
    (.bar.layout.left // []) as $left
    | (.bar.layout.centerBegin // []) as $centerBegin
    | (.bar.layout.center // []) as $center
    | (.bar.layout.centerEnd // []) as $centerEnd
    | (.bar.layout.right // []) as $right
    | ([($left[]), ($centerBegin[]), ($center[]), ($centerEnd[]), ($right[])] | map(select(.id == "omarchy.clock")) | first) as $clock
    | ([($left[]), ($centerBegin[]), ($center[]), ($centerEnd[]), ($right[])] | map(select(.id == "artr.workspaces")) | first) as $workspaces
    | .bar.background = "glassy"
    | .bar.layout.center = []
    | .bar.layout.right = (($right | map(select(.id != "omarchy.clock"))) + (if $clock then [$clock] else [] end))
    | .bar.layout.left = (($left | map(select(.id != "artr.workspaces"))) + (if $workspaces then [$workspaces] else [] end))
    | .bar.layout.centerEnd = ($centerEnd | map(select(.id != "artr.workspaces")))
    | .plugins = (((.plugins // []) | map(select(.id != "artr.osd"))) + [{"id":"artr.osd"}])
    | .disabledPlugins = (((.disabledPlugins // []) + ["omarchy.menu", "omarchy.dock", "omarchy.workspaces", "omarchy.osd"]) | unique)
    | .cloneSourceRestores = (((.cloneSourceRestores // []) + ["artr.menu", "artr.workspaces", "artr.osd"]) | unique)
  ' "$SHELL_JSON" > "${SHELL_JSON}.new" && mv "${SHELL_JSON}.new" "$SHELL_JSON"
  note "glassy menu bar, clock on the right, dock hidden, custom OSD enabled"
else
  echo "    shell.json not found; skipped" >&2
fi

if [[ "$INSTALL_THEME" == "1" ]]; then
  say "Theme"
  omarchy theme install "$THEME_REPO" || true
  omarchy theme install "$THEME_LIGHT_REPO" || true
  note "Sequoia (dark) and Sequoia Light are installed"
fi

say "Reload"
hyprctl reload >/dev/null 2>&1 || true
omarchy restart shell >/dev/null 2>&1 || true

printf '\n\033[1;32mDone.\033[0m Run \033[1momarchy theme set sequoia\033[0m to switch to the dark theme,\n'
printf 'or \033[1momarchy theme set sequoia-light\033[0m for the light one.\n\n'
