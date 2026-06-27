# Neovim Cheatsheet

Leader key is `<Space>`.

## Search
| Key | Action |
|---|---|
| `<C-n>` | Clear search highlight |

## Diagnostics
| Key | Action |
|---|---|
| `<leader>D` | Show full diagnostic for current line |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

## LSP
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `K` | Hover documentation |
| `gi` | Go to implementation |
| `gr` | Go to references |

## Text Objects

### Built-in Vim
| Keys | Object |
|---|---|
| `iw` / `aw` | Word / a word |
| `iW` / `aW` | WORD / a WORD |
| `is` / `as` | Sentence |
| `ip` / `ap` | Paragraph |
| `i'` / `a'` | Single quotes |
| `i"` / `a"` | Double quotes |
| `` i` `` / `` a` `` | Backticks |
| `i(` / `a(` | Parentheses |
| `i[` / `a[` | Brackets |
| `i{` / `a{` | Curly braces |
| `i<` / `a<` | Angle brackets |
| `it` / `at` | XML/HTML tags |

Usage: `d`/`c`/`y`/`v` + text object. Example: `daw` → delete a word.

### Treesitter
| Keys | Object |
|---|---|
| `af` / `if` | Function (outer/inner) |
| `ac` / `ic` | Class |
| `ap` / `ip` | Parameter |
| `ab` / `ib` | Block |

### Treesitter Navigation
| Key | Action |
|---|---|
| `]f` | Next function |
| `[f` | Previous function |
| `]c` | Next class |
| `[c` | Previous class |
| `]p` | Next parameter |
| `[p` | Previous parameter |

## Plugin Keybindings

### Flash (enhanced navigation)
| Key | Action |
|---|---|
| `s` + `char` + `char` | Jump to any visible match |
| `S` + `text` | Treesitter-aware jump |

Replaces vim's `s` and `S`. Type `s` then two characters to see highlighted labels.

### Telescope
| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Search help |

### Surround (`vim-surround`)
| Keys | Action |
|---|---|
| `ys` + motion + char | Add surround |
| `cs` + old + new | Change surround |
| `ds` + char | Delete surround |

### Comments (`Comment.nvim`)
| Key | Action |
|---|---|
| `gc` + motion / `gcc` | Toggle line comment |
| `gb` + motion | Toggle block comment |

### NvimTree
| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |

### Gitsigns
| Key | Action |
|---|---|
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hu` | Undo stage hunk |

## Python
| Key | Action |
|---|---|
| `<F5>` | Run current file (venv-aware) |

## Completion (nvim-cmp)
| Key | Action |
|---|---|
| `<C-n>` / `<C-p>` | Select next / previous item |
| `<C-f>` / `<C-d>` | Scroll documentation |
| `<CR>` | Confirm selection |
| `<C-e>` | Cancel completion |

Triggers automatically after 3 characters. Shows up to 8 candidates.
