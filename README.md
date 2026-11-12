# The macOS look for Omarchy

Everything that turns an [Omarchy](https://omarchy.org/) desktop into a macOS
one: SF Pro-style typography, a frosted glass menu bar, a Spotlight-style
launcher, rounded translucent windows, and the Sequoia theme.

![Sequoia dark](screenshots/dark.png)

![Sequoia light](screenshots/light.png)

## Install

```bash
git clone https://github.com/adhilroshan/omarchy-macos.git
cd omarchy-macos
./install.sh
```

Then pick a theme:

```bash
omarchy theme set sequoia        # dark
omarchy theme set sequoia-light  # light
```

Use `./install.sh --no-theme` to skip installing the themes.

## What it changes

| | |
|---|---|
| **Typography** | The shell (menu bar, menus, dock) renders in **Inter**, the closest free stand-in for SF Pro. Terminals keep their own monospace font. |
| **Menu bar** | Glassy: Hyprland blurs the wallpaper behind it, and the clock moves to the far right like macOS. |
| **Launcher** | `Super+Space` opens a Spotlight-style search field — wide, near the top of the screen, with a magnifier, a clear button, and its results in a separate panel below. |
| **Windows** | Rounded corners, a 1px hairline border, a soft drop shadow, and a slight translucency so the wallpaper shows through. |
| **Surfaces** | Menus, notifications and popups use a frosted material with light catching the top edge. |
| **Workspaces** | The workspace strip in the menu bar is a row of dots instead of numbers. |
| **Dock** | Hidden, the way a macOS desktop without a dock looks. |

## Themes

- [Sequoia](https://github.com/adhilroshan/omarchy-sequoia) — dark
- [Sequoia Light](https://github.com/adhilroshan/omarchy-sequoia-light) — light

Both carry Apple's macOS Sequoia system palette, the default blue accent, and
the authentic macOS Sequoia wallpapers.

## Files it writes

```
~/.local/share/fonts/inter/            Inter (SF Pro stand-in)
~/.local/share/fonts/nerd-symbols/     Nerd Font symbols, for the shell's icons
~/.config/fontconfig/fonts.conf
~/.config/fontconfig/conf.d/99-omarchy-inter-ui.conf
~/.config/omarchy/plugins/artr.menu/          Spotlight-style launcher
~/.config/omarchy/plugins/artr.workspaces/    dot-style workspace strip
~/.config/hypr/looknfeel.lua
~/.config/omarchy/shell.json                 bar layout, disabled plugins
~/.local/state/omarchy/toggles/hypr/         bar-glassy.lua, window-glassy.lua
```

Each file that already exists is copied to `<file>.bak.<timestamp>` first.

## Undo

Every file the installer touches has a timestamped backup next to it:

```bash
ls ~/.config/hypr/*.bak.*          # find them
cp ~/.config/hypr/looknfeel.lua.bak.20260101-120000 ~/.config/hypr/looknfeel.lua
```

Then reload:

```bash
hyprctl reload
omarchy restart shell
```

To undo only the fonts and fontconfig, delete `~/.local/share/fonts/inter`,
`~/.local/share/fonts/nerd-symbols` and `~/.config/fontconfig/conf.d/99-omarchy-inter-ui.conf`,
then run `fc-cache -f`.

## Credits

- Wallpapers are Apple's macOS Sequoia artwork, redistributed as part of the
  theme for personal desktop use.
- Inter is by [Rasmus Andersson](https://rsms.me/inter/) (SIL Open Font License).
- Nerd Fonts are by [ryanoasis](https://www.nerdfonts.com/) (SIL Open Font License).
- The base theme and shell come from [Omarchy](https://omarchy.org/).

## License

MIT
