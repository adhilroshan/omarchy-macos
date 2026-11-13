-- Change the default Omarchy look'n'feel.

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.08,
--   },
-- })

-- macOS-style rounded corners, a hairline border and a soft drop shadow.
-- The shell mirrors the rounding value, so bar and menu surfaces pick up
-- the same curve.
-- macOS Liquid Glass: windows are slightly translucent so the wallpaper and
-- whatever is behind shows through, with a soft blur. The shell surfaces get
-- their blur from the Hyprland glass rules.
hl.config({
  general = {
    border_size = 1,
  },

  decoration = {
    rounding = 10,

    active_opacity = 0.95,
    inactive_opacity = 0.90,

    dim_inactive = true,
    dim_strength = 0.08,

    shadow = {
      enabled = true,
      range = 14,
      render_power = 2,
      color = "rgba(00000060)",
      color_inactive = "rgba(00000025)",
    },

    blur = {
      enabled = true,
      size = 4,
      passes = 2,
      new_optimizations = true,
      xray = false,
      contrast = 1.0,
      brightness = 0.75,
      noise = 0.01,
      vibrancy = 0.35,
      vibrancy_darkness = 0.35,
      popups = true,
      special = true,
    },
  },
})

-- macOS-like view transitions.
-- Smooth, purposeful motion: windows fade/scale in, layers (menus, Spotlight)
-- appear with a gentle fade, and workspace slides feel continuous.
-- Curves tuned to feel like macOS: quick ease-out for entrances, ease-in-out
-- for moves, and a soft deceleration on exits.

-- Custom bezier curves matching macOS feel (ease-out, ease-in-out, ease-in)
hl.curve("macEaseOut", { type = "bezier", points = { { 0.16, 1.0 }, { 0.3, 1.0 } } })
hl.curve("macEaseInOut", { type = "bezier", points = { { 0.42, 0.0 }, { 0.58, 1.0 } } })
hl.curve("macEaseIn", { type = "bezier", points = { { 0.4, 0.0 }, { 1.0, 1.0 } } })

-- Global animation toggle (keep enabled)
hl.config({
  animations = {
    enabled = true,
  },
})

-- Window transitions: open with subtle pop, close with fade, move smoothly
hl.animation({ leaf = "windows", enabled = true, speed = 4.5, bezier = "macEaseOut", style = "popin 96%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.5, bezier = "macEaseOut", style = "popin 96%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.5, bezier = "macEaseIn", style = "popin 96%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.5, bezier = "macEaseInOut" })

-- Fade transitions (general UI fades)
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "macEaseOut" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "macEaseOut" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "macEaseIn" })

-- Layer transitions (menus, popups, Spotlight overlay)
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "macEaseOut", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "macEaseOut", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3.5, bezier = "macEaseIn", style = "fade" })

-- Special workspace (scratchpad-like overlays)
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "macEaseOut", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4, bezier = "macEaseOut", style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, bezier = "macEaseIn", style = "slide bottom" })

-- Workspace slide animation.
--
-- Omarchy ships with the workspace animation leaf turned off, and the leaf
-- that drives a workspace's slide offset inherits from it, so that offset
-- never animates. A three-finger swipe previews the next workspace by
-- moving that offset with your finger -- but on release the new workspace
-- snaps into place instead of sliding home, which is what makes the swipe
-- feel like it jerks. Turning the leaf back on lets the preview finish as
-- the slide it was, so the gesture ends the way it started.
--
-- This also gives ordinary workspace switches a slide, which is Hyprland's
-- default look. Remove these three lines to go back to the instant switch.
hl.animation({ leaf = "workspaces", enabled = true, speed = 5.5, bezier = "macEaseOut", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 5.5, bezier = "macEaseOut", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.5, bezier = "macEaseIn", style = "slide" })

-- Border color transition
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "macEaseOut" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
