-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Natural (touchpad-style) scrolling for everything.
-- The touchpad and the mouse wheel both move the content the same way your
-- fingers/hand move, like on a phone or a Mac.
hl.config({
  input = {
    -- Mice and other non-touchpad pointers (e.g. trackpoint, external mouse).
    natural_scroll = true,

    touchpad = {
      natural_scroll = true,
    },
  },
})

-- How the touchpad gestures feel.
--
-- Hyprland's defaults assume a long, deliberate swipe: 300px of finger
-- travel before a workspace switch commits, and only half of that distance
-- needed to let go and have it stick. On a touchpad that reads as the
-- gesture ignoring you until it suddenly snaps, which is what makes it feel
-- clunky. These values shorten the travel, let a quick flick commit on the
-- spot, and settle the axis early so a wobbling finger cannot cancel a
-- swipe halfway through.
hl.config({
  gestures = {
    -- Finger travel (px) that maps to a full screen-width slide. Tuned for
    -- a macOS-like feel: enough travel that the preview tracks 1:1 with the
    -- finger without committing prematurely, but not so much that it feels
    -- sluggish. The preview still follows the finger exactly regardless.
    workspace_swipe_distance = 180,

    -- Let go after this fraction of the travel and the switch commits.
    -- Higher value means you need to swipe further before it sticks,
    -- giving more control and preventing accidental switches.
    workspace_swipe_cancel_ratio = 0.40,

    -- A flick this fast commits even if it has not travelled far. Slightly
    -- higher threshold so only deliberate flicks commit, not casual drags.
    workspace_swipe_min_speed_to_force = 15,

    -- Decide left/right once this much travel has happened and stick to it.
    -- Higher threshold prevents wobbly fingers from cancelling a swipe
    -- halfway through, making the gesture feel more decisive.
    workspace_swipe_direction_lock_threshold = 25,

    -- Allow continuous swiping across multiple workspaces in one gesture,
    -- the way macOS Spaces lets you swipe through several desktops without
    -- lifting your fingers. Makes multi-workspace navigation feel fluid.
    workspace_swipe_forever = true,
  },
})

-- Touchpad gestures.
-- Three fingers left/right: switch workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Three fingers up: toggle fullscreen on the active window.
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })

-- Three fingers down: float (or re-tile) the active window.
hl.gesture({ fingers = 3, direction = "down", action = "float" })

-- Four fingers up/down: raise/lower the volume.
--
-- Registered as one vertical gesture rather than one per direction. A
-- four-finger swipe drifts sideways easily, and a direction-specific gesture
-- is dropped completely when that drift wins, so the volume would not move
-- at all (or would move the wrong way) on a sloppy swipe.
--
-- The action table gives the gesture start/update/finish callbacks, which
-- lets the volume follow the finger instead of taking a fixed 5% step per
-- swipe. One continuous swipe now covers the whole range, and the volume
-- keeps moving while the fingers are still down.
local VOLUME_BIN = (os.getenv("HOME") or "") .. "/.local/bin/touchpad-volume"
local VOLUME_PER_PIXEL = 0.25 -- percent of volume per pixel of finger travel
local VOLUME_STEP = 3 -- only ask the shell for a change every 3%

local volume = { travel = 0, sent = 0 }

local function volume_round(x)
  if x >= 0 then
    return math.floor(x + 0.5)
  else
    return math.ceil(x - 0.5)
  end
end

local function volume_send(step, show)
  if step == 0 then
    return
  end

  local cmd = VOLUME_BIN .. " " .. step
  if show then
    cmd = cmd .. " --show"
  end

  hl.dispatch(hl.dsp.exec_cmd(cmd))
end

hl.gesture({
  fingers = 4,
  direction = "vertical",
  action = {
    start = function()
      volume.travel = 0
      volume.sent = 0
    end,
    update = function(e)
      -- Finger travel, positive when the fingers move up.
      volume.travel = volume.travel - (e.delta and e.delta.y or 0)

      local want = volume_round(volume.travel * VOLUME_PER_PIXEL)
      local step = want - volume.sent

      if step >= VOLUME_STEP or step <= -VOLUME_STEP then
        volume.sent = volume.sent + step
        volume_send(step, false)
      end
    end,
    finish = function()
      local want = volume_round(volume.travel * VOLUME_PER_PIXEL)
      local step = want - volume.sent

      if step ~= 0 then
        volume.sent = volume.sent + step
        volume_send(step, true)
      end
    end,
  },
})

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Use natural (inverse) scrolling.
--       natural_scroll = true,
--
--       -- Use two-finger clicks for right-click instead of lower-right corner.
--       clickfinger_behavior = true,
--
--       -- Control the speed of your scrolling.
--       scroll_factor = 0.4,
--
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
-- o.window("foot", { scroll_touchpad = 2.0 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
