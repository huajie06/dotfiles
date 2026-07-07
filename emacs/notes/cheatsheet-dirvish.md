# Dirvish + consult-dir cheatsheet

Bindings come from `evil-collection` + dirvish defaults. Only `h`/`l` override
dirvish's history-forward/back to behave like vim (up/open).

## Global keybindings

| Key | Command | Action |
|---|---|---|
| `C-c d` | `my/dirvish-side` | Toggle/focus sidebar |
| `C-w l` | (from sidebar) | Move to code window |
| `C-c j` | `consult-dir` | Jump to directory (project/recent/home) |
| `C-x d` | `dirvish` | Open Dirvish at prompt |

## Inside Dirvish (sidebar or full)

### Navigation

| Key | Action |
|---|---|
| `j` / `k` | Next / previous file |
| `h` | Go up a directory |
| `l` | Open file / enter directory |
| `RET` | Open file / enter directory |
| `TAB` | Preview file inline |
| `gr` | Refresh |
| `~` | Jump to home |
| `.` | Toggle hidden files |
| `s` | Sort (name/date/size) |
| `z` | Extract — preview in side window |
| `zM` | Collapse all expanded subtrees |

### File operations

| Key | Action |
|---|---|
| `m` | Mark file |
| `u` | Unmark file |
| `U` | Unmark all |
| `C` | Copy marked/current file |
| `R` | Rename marked/current file |
| `D` | Delete marked/current file |
| `+` | Create directory |
| `C-x C-q` | wdired — edit filenames as text |

### Quit

| Key | Action |
|---|---|
| `q` | Close sidebar / quit Dirvish |

### Git

Git status icons show automatically in the left margin when inside a repo.
