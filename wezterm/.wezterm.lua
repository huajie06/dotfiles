local wezterm = require 'wezterm'
return {
  font = wezterm.font_with_fallback {
    { family = 'JetBrains Mono', weight = 'Medium' },
    { family = 'DejaVuSansM Nerd Font Mono', weight = 'Regular' },
  },
  font_size = 16.0,
  initial_cols = 100,
  initial_rows = 30,
  dpi = 96.0,

  color_scheme = 'Tokyo Night',
  colors = {
    foreground = '#a9b1d6',
    background = '#1a1b26',
    cursor_bg = '#c0caf5',
    cursor_border = '#c0caf5',
    cursor_fg = '#1a1b26',
    selection_bg = '#33467c',
    selection_fg = '#c0caf5',
    ansi = {
      '#1d202f',
      '#f7768e',
      '#9ece6a',
      '#e0af68',
      '#7aa2f7',
      '#bb9af7',
      '#7dcfff',
      '#c0caf5',
    },
    brights = {
      '#565f89',
      '#f7768e',
      '#9ece6a',
      '#e0af68',
      '#7aa2f7',
      '#bb9af7',
      '#7dcfff',
      '#a9b1d6',
    },
    tab_bar = {
      background = '#1a1b26',
      active_tab = {
        bg_color = '#7aa2f7',
        fg_color = '#1a1b26',
      },
      inactive_tab = {
        bg_color = '#1d202f',
        fg_color = '#565f89',
      },
      inactive_tab_hover = {
        bg_color = '#33467c',
        fg_color = '#c0caf5',
      },
      new_tab = {
        bg_color = '#1a1b26',
        fg_color = '#565f89',
      },
      new_tab_hover = {
        bg_color = '#33467c',
        fg_color = '#c0caf5',
      },
    },
  },

  hide_tab_bar_if_only_one_tab = true,
  tab_max_width = 32,
  enable_tab_bar = true,
  use_fancy_tab_bar = true,

  window_background_opacity = 0.93,
  window_decorations = 'RESIZE',
  window_padding = { left = 8, right = 8, top = 4, bottom = 4 },
  window_close_confirmation = 'NeverPrompt',

  term = 'wezterm',
  default_prog = { 'fish' },
  enable_kitty_graphics = true,
  enable_wayland = false,

  adjust_window_size_when_changing_font_size = false,
  warn_about_missing_glyphs = false,
}
