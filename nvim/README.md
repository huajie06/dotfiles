# nvim

Personal Neovim config — sourced from `~/repos/dotfiles/nvim/init.lua`.

## Plugin Manager

Uses [lazy.nvim](https://github.com/folke/lazy.nvim). Auto-bootstraps on first run.

- `:Lazy` — open plugin UI
- `:Lazy update` — update all plugins
- `:Lazy sync` — sync declared plugins

## Plugins

| Plugin | Purpose |
|---|---|
| [tokyonight](https://github.com/folke/tokyonight.nvim) | Colorscheme |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Text objects by syntax tree |
| [flash.nvim](https://github.com/folke/flash.nvim) | Enhanced f/F/t/T navigation |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder (files, grep, buffers, help) |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client (pyright for Python) |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP installer |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in gutter |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Toggle comments |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Status line |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Surround with quotes/brackets/tags |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer |

## Cheatsheet

See [CHEATSHEET.md](./CHEATSHEET.md).
