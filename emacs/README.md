# Emacs Configuration

Modular Emacs 30.2 config with Evil keybindings, geared toward Python data science and Org mode workflows. Works on Linux and Windows.

## How it loads

Two deployment strategies are supported:

**A. Load directly from the repo (recommended)**

In `~/.emacs.d/init.el`, put a single form:

```elisp
(load "~/repos/dotfiles/emacs/init.el")
```

`init.el` then figures out its own directory, loads `early-init.el` explicitly (since Emacs only auto-discovers it in `~/.emacs.d/`), adds `lisp/` to the load path, and requires each module in dependency order.

**B. Copy to `~/.emacs.d/`**

```bash
bash emacs/move_files.sh
```

Creates a dated backup under `~/.emacs.d.bak/` before deploying. In this mode Emacs auto-loads `early-init.el` from `~/.emacs.d/`, and `init.el` acts as a no-op passthrough — it still detects its path and sets up `lisp/` on the load path.

## Architecture

```
emacs/
├── early-init.el          # Startup settings, UI chrome, scratch buffer
├── init.el                # Entry point: resolves paths, loads early-init + modules
├── lisp/                  # All configuration modules
│   ├── init-core.el       # Package bootstrap + general Emacs settings
│   ├── init-ui.el         # Doom modeline (text-based, no icons)
│   ├── init-tools.el      # Magit, Projectile, TRAMP, ibuffer, etc.
│   ├── init-completion.el # Corfu/Cape/Vertico/Consult/Embark
│   ├── init-evil.el       # Evil, evil-collection, evil-commentary, evil-anzu, undo-fu/vundo stack
│   ├── init-dirvish.el    # Dirvish (enhanced Dired), sidebar, evil bindings
│   ├── init-python.el     # Tree-sitter, python-ts-mode, my-python-run, REPL
│   ├── init-org.el        # Org mode, capture, babel, clocking
│   └── init-daily-log.el  # Daily activity logging with calendar view
├── test/                  # Ad-hoc scripts, experiments (not loaded by Emacs)
├── notes/                 # Personal reference (not loaded by Emacs)
└── move_files.sh          # Alternative deployment script with backup
```

## Load order and dependencies

Modules are loaded in this order by `init.el`. Each module depends only on modules listed before it:

1. **`init-core`** — No dependencies. Sets up MELPA, `use-package`, general Emacs defaults (backups, auto-save, electric modes, line numbers, hooks).
2. **`init-ui`** — Depends on core. Doom modeline; picks up evil state automatically once evil loads later.
3. **`init-tools`** — Depends on core. Standalone tools with no evil or completion dependency: Magit, Projectile, TRAMP, Anzu, aggressive-indent, indent-bars, ibuffer.
4. **`init-completion`** — Depends on core. Minibuffer (Vertico/Consult/Embark/Orderless/Marginalia) and in-buffer (Corfu/Cape) completion. Evil integration is deferred with `with-eval-after-load 'evil`.
5. **`init-evil`** — Depends on tools (for Anzu). Evil mode, evil-collection, evil-surround, evil-commentary, evil-anzu, undo-fu/undo-fu-session/vundo. Custom `_`-as-word text objects.
6. **`init-dirvish`** — Depends on evil. Dirvish sidebar with vim-style `j`/`k`/`h`/`l` navigation, collapse toggle, Evil normal state.
7. **`init-python`** — Depends on core. Loads `python.el` up-front. Evil keybindings deferred. Tree-sitter grammars, `python-ts-mode` remap, `# %%` cell navigation, venv detection, `my-python-run` bound to `<f5>`.
8. **`init-org`** — Depends on core. Forces org to load via `(require 'org-clock)`. Capture templates, babel, org-download, clock summary dynamic blocks.
9. **`init-daily-log`** — Depends on org. Daily activity logging with org-capture + calendar/table views for visualizing habits (workout, reading, diet).

A module can be disabled by commenting out its `require` in `init.el`.

## Daily log system

Capture daily activities (workout, reading, diet, etc.) into `~/org/daily-log.org` via org-capture, then visualize them in a color-coded month calendar.

### Capturing entries

Run `C-c c`, then choose `d` to capture an activity under today's date in a datetree:

```
* 2026
** 2026-05 May
*** 2026-05-03 Sunday
**** Workout
ran 5k
**** Reading
30 minutes
**** Diet
salad + chicken
```

Type optional details below the activity name. Multiline notes are fine, which
is useful for workouts, meals, or other richer logs. `C-c C-c` to finish.

### Calendar view

`C-c v` opens the calendar buffer (`*Daily Log*`).

```
Activity: Workout        Range: last 31 days        Count: 8 / 31
──────────────────────────────────────────────────────────────────────

                   May 2026

 Mon Tue Wed Thu Fri Sat Sun
   .   .   .   .   1   2   3
   4    5    6    7    8    9   10
   ...
```

- Day numbers are color-coded when an activity occurred (red=Workout, blue=Reading, orange=Diet)
- Today is highlighted
- **n** / **p** — navigate months
- **+** / **-** — change summary range (30 → 60 → 90 → 180 → 365 days)
- **g** — switch to a different activity
- **t** — switch to table view
- **RET** — open date's detail popup in a side window
- **c** — run capture from the view
- **q** — quit

### Table view

`C-c t` opens a cross-activity table with one row per day. It keeps the same
activity colors as the calendar, but each activity cell shows a compact detail
snippet when the entry has body text. Empty activity headings still show the
activity letter, and missing activities show `.`.

```
Date            Workout        Reading        Diet
2026-05-03 Sun  ran 5k         30 minutes     salad + chicken
```

- **n** / **p** — scroll by 30 days
- **j** / **k** — move down/up one line
- **+** / **-** — change the range (30 → 60 → 90 → 180 → 365 days)
- **v** — switch back to the calendar view
- **RET** — open the date's subtree in `daily-log.org`
- **c** — run capture from the view
- **q** — quit

### Customizing activities

Edit `my/daily-log-activities` in `lisp/init-daily-log.el` to add or change activities. Each entry needs a name, a single-letter code, and a face:

```elisp
'(("Workout"    "W" my/daily-log-face-workout)
  ("Reading"    "R" my/daily-log-face-reading)
  ("Diet"       "D" my/daily-log-face-diet)
  ;; Add more as needed: ("Medication" "M" my/daily-log-face-medication)
  )
```

## `early-init.el` and the startup sequence

`early-init.el` is loaded explicitly by `init.el` (rather than auto-discovered from `~/.emacs.d/`). This means:

- The `inhibit-startup-screen` and `initial-buffer-choice` setq calls may run too late to affect Emacs's built-in startup screen logic.
- An `emacs-startup-hook` fallback switches to `*scratch*` after all init finishes, guaranteeing you always land there.
- GUI chrome settings (`menu-bar-mode`, `tool-bar-mode`, `blink-cursor-mode`) still take effect but won't prevent an initial flicker when loading from the repo (mode A). They prevent flicker when `early-init.el` is auto-discovered from `~/.emacs.d/` (mode B).

## Design conventions

- **No `custom-file`**: all settings are explicit `setq` inside `use-package` blocks. Nothing writes to `custom-set-variables`.
- **GUI frame size** is restored from `~/.emacs.d/frame-geometry.el`. Run `M-x my/save-frame-geometry` after resizing the frame to update it. Frame position is intentionally left to the window manager: KDE Wayland ignores application positioning requests, so use a KWin Window Rule if fixed placement is needed.
- **`:custom` for defcustoms, `:bind` for keys, `:config` for everything else** — keeps intent clear.
- **Evil keybindings** use nested `with-eval-after-load 'evil ... with-eval-after-load '<package>` so neither load order nor deferred loading breaks them.
- **Python mode** remapped via `major-mode-remap-alist` (`python-mode` → `python-ts-mode`), not by patching `auto-mode-alist`.
- **Path resolution** uses `(file-name-directory (or load-file-name buffer-file-name))` so the config works regardless of where the repo is checked out.
- **Windows compatibility**: Python executable and venv paths use OS-aware logic (`system-type` check, `executable-find` fallback). Path separators are handled by Emacs's `expand-file-name` which is platform-native.

## Known issues

These pre-date the modular refactor and aren't yet resolved:

- **`avy` not declared as dependency**: `init-evil.el` binds `SPC` to `avy-goto-char-2`, but there is no `(use-package avy ...)` anywhere. It works if `avy` was installed transitively by another package, but will error on a clean install. Fix: add `(use-package avy)` to `init-tools.el` or `init-evil.el`.
- **`<leader>` keybindings broken**: `init-python.el` binds `<leader>l`/`<leader>b`/`<leader>a` via `evil-define-key`, but these require the `evil-leader` package (not installed). The bindings silently do nothing. Fix: either install `evil-leader` and configure a leader key, or use `general.el` for leader-based keybindings.

## `test/` directory

For ad-hoc scripts, experiments, and temporary elisp not tracked or deployed. Load manually with `M-x eval-buffer` or `load-file`.

## `notes/` directory

Personal reference material (cheatsheets, etc.). Not loaded by Emacs and not deployed.
