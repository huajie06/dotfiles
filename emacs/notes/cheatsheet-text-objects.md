# Evil Text Objects Cheatsheet

## Pattern

```
[count]<operator>[i|a]<text-object>
```

| Part | Meaning |
|---|---|
| `count` | Repeat (e.g. `d3w`) |
| `operator` | `d` delete, `c` change, `y` yank, `v` select, `gu` lowercase, `gU` uppercase, `=` indent, `gc` comment |
| `i` | **inner** — inside, no delimiters/whitespace |
| `a` | **a/around** — includes surrounding delimiters or whitespace |

## Examples

### Word / WORD

| Keys | Cursor on `foo` in `foo_bar baz` | Result |
|---|---|---|
| `diw` | `foo_bar` | `baz` (`_` is part of word) |
| `ciw` | `foo_bar` | `baz` (insert mode) |
| `yiw` | `foo_bar` | yanked `foo_bar` |
| `daw` | `foo_bar` | `baz` (removes trailing space) |
| `diW` | `foo_bar` | ` baz` (WORDs = whitespace delimited; `_` normal) |

### Quotes

| Text | Keys | Result |
|---|---|---|
| `"hello world"` | `di"` | `""` |
| `"hello world"` | `ci"` | `""` (insert mode) |
| `"hello world"` | `yi"` | yanked `hello world` |
| `"hello world"` | `da"` | `(nothing, quotes gone)` |
| `'hello'` | `ci'` | `''` (insert mode) |

### Brackets / Parentheses

| Text | Keys | Result |
|---|---|---|
| `(a, b, c)` | `di(` | `()` |
| `(a, b, c)` | `da(` | `(nothing, parens gone)` |
| `{k: v}` | `ci{` | `{}` (insert mode) |
| `[1, 2]` | `yi[` | yanked `1, 2` |
| `<div>` | `dit` | `<div></div>` (no content) |
| `<div>x</div>` | `cit` | `<div></div>` |
| `<div>x</div>` | `dat` | `x` (tag removed) |

### Surround (evil-surround)

| Keys | Effect |
|---|---|
| `ysiw"` | Wrap word in `"..."` |
| `ysiw2"` | Wrap in `"..."` (uses last used surround) |
| `cs"'` | Change surrounding `"` to `'` |
| `cs'<q>` | Change `'` to `<q>...</q>` |
| `ds"` | Delete surrounding `"` |
| `yssb` | Surround entire line in `()` |
| `ysiw]` | Wrap word in `[ ]` (space inside) |
| `ysiw<em>` | Wrap word in `<em> </em>` |

### Commentary (evil-commentary)

| Keys | Effect |
|---|---|
| `gciw` | Comment word |
| `gcap` | Comment paragraph |
| `gcc` | Comment / uncomment line |
| `gc2j` | Comment 2 more lines down |

### Visual mode

| Keys | Effect |
|---|---|
| `viw` | Select inner word |
| `vip` | Select paragraph → then `d`/`c`/`y`/`gU` |
| `va(` | Select parens + content |
| `vit` | Select inner tag content |

### Other operators

| Keys | Effect |
|---|---|
| `guiw` | Lowercase word |
| `gUiw` | Uppercase word |
| `=ip` | Reindent paragraph |

## Built-in text objects

| Object | `i` (inner) | `a` (around) |
|---|---|---|
| **word** | `iw` — word (`_` is part of word) | `aw` — word + space |
| **WORD** | `iW` — WORD (whitespace-delimited) | `aW` |
| **sentence** | `is` | `as` |
| **paragraph** | `ip` | `ap` |
| **double quote** | `i"` | `a"` |
| **single quote** | `i'` | `a'` |
| **backtick** | `` i` `` | `` a` `` |
| **parentheses** | `i(` / `ib` | `a(` / `ab` |
| **curly braces** | `i{` / `iB` | `a{` / `aB` |
| **square brackets** | `i[` | `a[` |
| **angle brackets** | `i<` | `a<` |
| **tag** (HTML/XML) | `it` | `at` |

## Customizations in this config

| Remap | What changed |
|---|---|
| `iw` / `aw` | `_` treated as part of word (via `evil-symbol`) — `my_var` is one word |

## Tips

- `daw` deletes word *and* trailing space — repeat `.` to chain.
- Combine with count: `2daw` deletes 2 words + space.
- `diw` then `p` replaces word with yanked text.
- `viw` then `d`/`c`/`y`/`~` works on the selection.
