local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.window_background_image = '/home/bedawang/gandalf-computer-wizzard.jpg'
config.window_background_image_hsb = {
  brightness = 0.2,
  hue = 1.0,
  saturation = 1.0,
}

--config.font = wezterm.font("FiraCode Nerd Font")
config.font = wezterm.font_with_fallback({
  { family = "FiraCode Nerd Font" },
  { family = "Symbols Nerd Font" },
  { family = "DejaVu Sans Mono" },
  { family = "JetBrains Mono" },
  { family = "Noto Color Emoji", scale = 0.45 }
})

config.font_size = 13.0
config.line_height = 1.0

config.allow_square_glyphs_to_overflow_width = "Never" -- important for tables
config.freetype_load_target = "Light" -- optional: can help with sharpness

 --font = wezterm.font("Fira Mono"),
  -- This forces ambiguous-width characters to be single-width
  -- (see WezTerm docs for details)
  -- allow_square_glyphs_to_overflow_width = false,


return config


