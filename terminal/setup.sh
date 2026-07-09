#!/usr/bin/env bash
set -euo pipefail

profile_name="${TERMINAL_PROFILE_NAME:-Personal Tokyo Night}"
font_name="${TERMINAL_FONT:-FiraCodeNFM-Reg}"
font_size="${TERMINAL_FONT_SIZE:-20}"

osascript \
  -e 'on run argv' \
  -e 'set profileName to item 1 of argv' \
  -e 'set fontName to item 2 of argv' \
  -e 'set fontSize to item 3 of argv as integer' \
  -e 'tell application "Terminal"' \
  -e 'if not (exists settings set profileName) then make new settings set with properties {name:profileName}' \
  -e 'tell settings set profileName' \
  -e 'set font to fontName' \
  -e 'set font size to fontSize' \
  -e 'set number of columns to 120' \
  -e 'set number of rows to 30' \
  -e 'set background color to {6682, 6939, 9766}' \
  -e 'set normal text color to {49344, 51914, 62965}' \
  -e 'set bold text color to {49344, 51914, 62965}' \
  -e 'set cursor color to {49344, 51914, 62965}' \
  -e 'end tell' \
  -e 'set default settings to settings set profileName' \
  -e 'set startup settings to settings set profileName' \
  -e 'if (count of windows) > 0 then set current settings of selected tab of front window to settings set profileName' \
  -e 'end tell' \
  -e 'end run' \
  -- "$profile_name" "$font_name" "$font_size"

echo "Updated Terminal profile: $profile_name"
echo "Font: $font_name $font_size"
