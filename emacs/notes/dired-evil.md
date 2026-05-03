# Emacs Dired + Evil Cheatsheet

### 🧠 Core Concepts

* **Normal Mode:** Navigation is like Vim (`j/k`). File actions are usually **Capital Letters** (`C`, `D`, `R`).
* **Marking:** Dired operates on **marked files** (`*`). If nothing is marked, it acts on the file under the cursor.
* **WDired:** The "Killer Feature." Turns the file list into a standard text buffer so you can rename files by typing.

---

### 1. Navigation & Views

| Action            | Key        | Notes                                      |
|-------------------|------------|--------------------------------------------|
| **Open / Enter**  | `RET`      | Opens file or enters directory             |
| **Up Directory**  | `-`        | Go to parent folder                        |
| **Next / Prev**   | `j` / `k`  | Standard Vim motion                        |
| **Top / Bottom**  | `gg` / `G` | Jump to start/end of list                  |
| **Refresh View**  | `g r`      | Reloads directory listing                  |
| **Open in Split** | `g O`      | (`g` then `Shift+O`) Opens in other window |
| **Sort**          | `o`        | Toggles sort by Name / Date                |
| **Hide Details**  | `(`        | Toggles permissions/owner columns          |

### 2. File Operations

*Applies to **marked** files. If no marks, applies to **current** file.*

| Action            | Key     | Mnemonic                           |
|-------------------|---------|------------------------------------|
| **Copy**          | `C`     | **C**opy to destination            |
| **Move / Rename** | `R`     | **R**ename (moves if path changes) |
| **Delete**        | `D`     | **D**elete (asks for confirm)      |
| **Create Folder** | `+`     | Prompts for name                   |
| **Create File**   | `SPC .` | (Or `C-x C-f`) Standard find-file  |
| **Perms (chmod)** | `M`     | **M**ode                           |
| **Owner (chown)** | `O`     | **O**wner                          |
| **Shell Cmd**     | `!`     | Run terminal command on file       |

### 3. Marking Files

| Action         | Key   | Description                      |
|----------------|-------|----------------------------------|
| **Mark**       | `m`   | Selects current file             |
| **Unmark**     | `u`   | Unselects current file           |
| **Unmark ALL** | `U`   | Clears all marks                 |
| **Toggle**     | `* t` | Inverts selection                |
| **Regex Mark** | `% m` | Selects files matching a pattern |

### 4. Editable Dired (WDired)

*Allows you to batch rename files like text.*

1. **Enter:** Press `C-x C-q`. (Modeline changes to `Editable Dired`).
2. **Edit:** Use standard Vim keys (`cw`, `x`, `s`) to change filenames.
3. **Finish:**

| Action             | Standard Key | Evil Key* |
|--------------------|--------------|-----------|
| **Save & Exit**    | `C-c C-c`    | `ZZ`      |
| **Abort / Cancel** | `C-c C-k`    | `ZQ`      |

**Note: Evil keys (`ZZ`/`ZQ`) only work if you add `wdired` to your `evil-collection-init` list.*

---

### 🚀 Recommended Next Steps

**1. Fix your Config for WDired**
To make `ZZ` and `ZQ` work in editable mode, update your config:

```elisp
(evil-collection-init '(magit dired wdired ibuffer))

```

**2. Learn `dired-jump**`
This command jumps from *any file buffer* directly to that file's location in a Dired buffer.

* **Command:** `M-x dired-jump`
* **Mapping:** usually `C-x C-j` (Emacs default) or you can bind it to something like `SPC f d` if you use a leader key. It is the best way to "go up" from a file to its folder.

**3. Visual Polish**
If you find Dired hard to read, look into **`nerd-icons-dired`** or **`all-the-icons-dired`**. These packages add file icons (like folders, Python logos, etc.) next to the filenames, making it much faster to visually scan directories.
