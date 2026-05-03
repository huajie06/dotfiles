# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

Personal dotfiles — primarily an Emacs configuration with Evil (vim) keybindings, plus a VSCode settings backup. The Emacs config targets Python data science workflows, Org mode (notes, LeetCode tracking, clocking), and ibuffer-based buffer management. Targets Emacs 30.2.

## Deploying changes

Two modes are supported:

**A. Load directly from the repo (primary workflow)**

`~/.emacs.d/init.el` contains a single form: `(load "~/repos/dotfiles/emacs/init.el")`. The repo's `init.el` then resolves its own directory, explicitly loads `early-init.el`, and requires all modules. No copy step needed.

**B. Copy to `~/.emacs.d/`**

```bash
bash emacs/move_files.sh
```

Creates a dated backup under `~/.emacs.d.bak/` before deploying. In this mode Emacs auto-discovers `early-init.el`.

The repo is the source of truth in both cases; edits should be made here.

## Emacs configuration architecture

The config is split into modular, topic-based files loaded in dependency order. See `emacs/README.md` for the full rationale.

**Entry points:**
- **`emacs/early-init.el`** — Startup settings (inhibit startup screen, `*scratch*` buffer), frame geometry, UI chrome, theme. Loaded explicitly by `init.el` so it works in deployment mode A.
- **`emacs/init.el`** — Resolves `my-config-path` from its own file location, loads `early-init.el`, adds `lisp/` to `load-path`, then `require`s each module in dependency order.

**Modules in `emacs/lisp/` (loaded in this order):**
- `init-core.el` — Package archives (MELPA), `use-package` config, general Emacs settings (backups, auto-save, paren matching, electric modes, line numbers, auto-revert, hooks).
- `init-ui.el` — Doom modeline configuration.
- `init-tools.el` — Magit, Projectile, TRAMP, Anzu, markdown-mode, aggressive-indent, indent-bars, ibuffer/ibuffer-project.
- `init-completion.el` — Corfu (in-buffer popup), Cape (backends), Vertico/Orderless/Marginalia (minibuffer), Consult, Embark.
- `init-evil.el` — Evil mode, evil-collection, evil-surround, evil-anzu, plus the undo stack (undo-fu, undo-fu-session, vundo).
- `init-python.el` — Tree-sitter grammars, `python-ts-mode` remap, Python shell, `# %%` cell navigation, venv detection, REPL keybindings.
- `init-org.el` — Org mode with capture templates, babel, org-tempo, org-download, clock summary dynamic block.
- `init-daily-log.el` — Daily activity logging via org-capture into `~/org/daily-log.org`, with a per-activity color-coded month calendar view (`C-c v`).

**Other files:**
- `emacs/README.md` — Detailed architecture docs, load order rationale, design conventions.
- `emacs/test/` — Ad-hoc scripts and experiments, not loaded by Emacs.
- `emacs/notes/dired-evil.md` — Personal cheatsheet for Dired + Evil, not loaded by Emacs.
- `vscode/settings.json` — Backed-up VSCode settings. Not deployed by the shell script.

## Key design patterns

- **No `custom-set-variables` or `custom-file`**: all settings are explicit `setq` calls inside `use-package` blocks.
- **Python mode remapping**: `python-mode` is remapped to `python-ts-mode` via `major-mode-remap-alist`, not by hacking `auto-mode-alist`.
- **Evil keybinding convention**: packages that need Evil integration use `evil-define-key` inside nested `with-eval-after-load 'evil ... with-eval-after-load '<package>` to ensure both are loaded.
- **Module isolation**: each `lisp/init-*.el` is self-contained and can be disabled by commenting out its `require` in `init.el`. Dependencies between modules are documented by load order.
- **Cross-platform**: Python executable and venv paths use OS-aware logic (`system-type` check, `executable-find` fallback). All path operations use Emacs's `expand-file-name` which handles platform separators natively.
