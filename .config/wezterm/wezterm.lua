local wezterm = require 'wezterm'
return {
  -- Choose the font family you installed
  font = wezterm.font("Hack Nerd Font Mono", {weight="Regular"}),

  -- Optional: set a comfortable size
  font_size = 16.0,

  -- Fallback fonts (helpful if a glyph is missing)
  font_rules = {
    {
      -- Emoji fallback
      intensity = "Bold",
      italic = false,
      font = wezterm.font("Noto Color Emoji"),
    },
  },

  -- Other nice defaults (you can keep or remove)
  color_scheme = "OneHalfDark",
  hide_tab_bar_if_only_one_tab = true,
}
