# Neovim Cheatsheet

Leader key is `<Space>`.

## Text Objects

Usage: `d` (delete), `c` (change), `y` (yank/copy), `v` (select) **+** text object.
Example: `daw` → **d**elete **a** **w**ord. `ci"` → **c**hange **i**nside double **"**uotes.

### Understanding `i` vs `a`

| Prefix | Meaning | Selects |
|---|---|---|
| `i` | **inside** | Content only, excluding delimiters/whitespace |
| `a` | **a** / **around** | Content **+** delimiters/surrounding whitespace |

Examples:

| Command | `i` (inside) | `a` (around) |
|---|---|---|
| On `(hello)` | `di(` → deletes `hello` leaving `()` | `da(` → deletes `(hello)` |
| On `"foo"` | `di"` → deletes `foo` leaving `""` | `da"` → deletes `"foo"` |
| On `hello world` cursor mid-word | `diw` → deletes the word | `daw` → deletes word + trailing space |

This matters most for quotes and brackets — `i` keeps the delimiters, `a` takes them too.

### Built-in Vim
| Keys | Object |
|---|---|
| `iw` / `aw` | Word / a word |
| `iW` / `aW` | WORD (space-delimited) |
| `is` / `as` | Sentence |
| `ip` / `ap` | Paragraph |
| `i'` / `a'` | Single quotes |
| `i"` / `a"` | Double quotes |
| `` i` `` / `` a` `` | Backticks |
| `i(` / `a(` | Parentheses `(` `)` |
| `i[` / `a[` | Brackets `[` `]` |
| `i{` / `a{` | Curly braces `{` `}` |
| `i<` / `a<` | Angle brackets `<` `>` |
| `it` / `at` | XML/HTML tags |

### Treesitter (syntax-aware)
| Keys | Object |
|---|---|
| `af` / `if` | Function (outer/inner) |
| `ac` / `ic` | Class |
| `ap` / `ip` | Parameter |
| `ab` / `ib` | Block |

These understand syntax, not just delimiters. Example: `vif` selects entire function body; `daf` deletes the whole function including the `def`/`function` keyword.

### Treesitter Navigation
| Key | Action |
|---|---|
| `]f` | Next function |
| `[f` | Previous function |
| `]c` | Next class |
| `[c` | Previous class |
| `]p` | Next parameter |
| `[p` | Previous parameter |

### Surround (`vim-surround`)
Combine with motions and text objects:

| Keys | Action | Example |
|---|---|---|
| `ys` + motion + char | Add surround | `ysiw"` → wraps word in `"word"` |
| `cs` + old + new | Change surround | `cs"'` → `"foo"` → `'foo'` |
| `ds` + char | Delete surround | `ds"` → `"foo"` → `foo` |
| `yss` + char | Surround whole line | `yss)` → wraps line in `( ... )` |
| `yS` + motion + char | New line + indent | `ySip#` → wraps paragraph in `#<newline>...` |

Tip: use text objects with `ys`: `ysaf(` → wraps current function in parens.

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

### Comments (`Comment.nvim`)
| Key | Action |
|---|---|
| `gc` + motion / `gcc` | Toggle line comment |
| `gb` + motion | Toggle block comment |

### NvimTree
| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |
| `r` | Rename / move file |
| `a` | Create new file |
| `d` | Delete file |
| `c` | Copy file |
| `p` | Paste file |
| `x` | Cut file |
| `y` | Copy filename to clipboard |

### Gitsigns
| Key | Action |
|---|---|
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hu` | Undo stage hunk |

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

## Python
| Key | Action |
|---|---|
| `<F5>` | Run current file (venv-aware, auto-formats on save) |

## Completion (nvim-cmp)
| Key | Action |
|---|---|
| `<C-n>` / `<C-p>` | Select next / previous item |
| `<C-f>` / `<C-d>` | Scroll documentation |
| `<CR>` | Confirm selection |
| `<C-e>` | Cancel completion |

Triggers automatically after 3 characters. Shows up to 8 candidates.
