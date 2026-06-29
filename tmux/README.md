# Tmux Cheatsheet

Prefix is `C-b` unless noted.

## Panes

| Key | Action |
|---|---|
| `C-b %` | Split horizontally |
| `C-b "` | Split vertically (default) |
| `C-b \|` | Split horizontally (custom) |
| `C-b -` | Split vertically (custom) |
| `C-b h/j/k/l` | Navigate pane left/down/up/right |
| `C-b H/J/K/L` | Resize pane ←↓↑→ (repeatable) |
| `M-h/j/k/l` | Navigate panes without prefix |
| `C-b x` | Kill pane |
| `C-b z` | Zoom pane (toggle fullscreen) |
| `C-b q` | Show pane numbers |
| `C-b o` | Next pane |
| `C-b ;` | Last pane |
| `C-b { / }` | Swap pane left / right |
| `C-b !` | Break pane to new window |

## Windows

| Key | Action |
|---|---|
| `C-b c` | Create window |
| `C-b ,` | Rename window |
| `C-b .` | Move window (prompt for number) |
| `C-b N` | Go to window N (e.g. `C-b 1`) |
| `C-b n` | Next window |
| `C-b p` | Previous window |
| `C-b l` | Last active window |
| `C-b &` | Kill window |
| `C-b f` | Find window by name |
| `C-b w` | List / choose window |

## Sessions

| Key | Action |
|---|---|
| `C-b d` | Detach |
| `C-b s` | Interactive session picker |
| `C-b $` | Rename session |
| `C-b (` | Previous session |
| `C-b )` | Next session |
| `C-b L` | Last session |
| `tmux new -s name` | New session (from shell) |
| `tmux attach -t name` | Attach (from shell) |

## Copy Mode (vi keys)

| Key | Action |
|---|---|
| `C-b [` | Enter copy mode |
| `C-b PgUp` | Enter copy mode + scroll up |
| `v` | Begin selection |
| `V` | Select line |
| `C-v` | Toggle rectangle selection |
| `y` | Yank selection (copies to clipboard) |
| `/` | Search forward |
| `?` | Search backward |
| `n / N` | Next / previous match |
| `Mouse drag` | Select and copy (mouse on) |
| `Esc` | Cancel |
| `C-b ]` | Paste |

## Misc

| Key | Action |
|---|---|
| `C-b r` | Reload config |
| `C-b F12` | Toggle prefix (pass C-b through) |
| `C-b C-b` | Send literal prefix to pane |
| `C-b :` | Command prompt |
| `C-b ?` | List all keybindings |
| `C-b t` | Big clock |
