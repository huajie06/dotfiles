# Dirvish + consult-dir cheatsheet

## Global keybindings

| Key | Command | Action |
|---|---|---|
| `C-c d` | `my/dirvish-side` | Toggle/ focus sidebar (opens & focuses, closes if focused) |
| `C-w l` | (from sidebar) | Move to code window |
| `C-c j` | `consult-dir` | Jump to directory (project/recent/home) |
| `C-x d` | `dirvish` | Open Dirvish at prompt (replaces dired) |

## Inside Dirvish (sidebar or full)

### Navigation

| Key | Action |
|---|---|
| `n` / `j` | Next file |
| `p` / `k` | Previous file |
| `RET` | Open file / enter directory |
| `^` or `h` | Go up a directory |
| `l` | Forward in history |
| `r` | Back in history |
| `~` | Jump to home |
| `g` | Refresh |
| `.` | Toggle hidden files |
| `s` | Sort (name/date/size) |

### Preview

| Key | Action |
|---|---|
| `TAB` | Preview file inline |
| `z` | Extract — preview in side window |
| `q` | Close sidebar / quit Dirvish |

### File operations

| Key | Action |
|---|---|
| `m` | Mark file |
| `u` | Unmark file |
| `C` | Copy marked/current file |
| `R` | Rename marked/current file |
| `D` | Delete marked/current file |
| `+` | Create directory |
| `C-x C-q` | wdired — edit filenames as text |

### Git

Git status icons show automatically in the left margin when inside a repo.
