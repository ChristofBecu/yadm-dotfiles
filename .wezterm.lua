local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 12.0

return config

