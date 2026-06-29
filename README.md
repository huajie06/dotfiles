# dotfiles

Personal config files.

| Config | Description |
|---|---|
| [emacs/](emacs/) | Modular Evil-based config for Python data science and Org mode |
| [nvim/](nvim/) | Neovim config |
| [fish/](fish/) | Fish shell config |
| [ghostty/](ghostty/) | Ghostty terminal config |
| [wezterm/](wezterm/) | WezTerm terminal config |
| [vscode/](vscode/) | VSCode `settings.json` backup |

## Quick start

Add this to `~/.emacs.d/init.el`:

```elisp
(load "~/repos/dotfiles/emacs/init.el")
```

Everything else resolves from the repo path. See [emacs/README.md](emacs/README.md) for details.
