local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.window_background_image = '/home/bedawang/gandalf-computer-wizzard.jpg'
config.window_background_image_hsb = {
  brightness = 0.1,
  hue = 1.0,
  saturation = 1.0,
}

config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 12.0


return config

