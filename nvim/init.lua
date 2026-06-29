-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"

vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.mkdir(vim.fn.stdpath("data") .. "/lazy", "p")
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        theme = "wave",
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "python", "lua", "javascript", "typescript", "json", "markdown", "html", "css", "yaml", "toml", "bash" },
        auto_install = true,
        highlight = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["ap"] = "@parameter.outer",
              ["ip"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]p"] = "@parameter.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[p"] = "@parameter.outer",
            },
          },
        },
      })
    end,
  },

  -- Treesitter textobjects
  { "nvim-treesitter/nvim-treesitter-textobjects", event = "VeryLazy" },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Search text" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Search help" },
    },
  },

  -- Flash.nvim — enhanced f/F/t/T navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
    },
    opts = {},
  },

  -- Which-key — shows keybinding suggestions as you type
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Mason — LSP server installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },

  -- Mason-lspconfig — bridges mason to lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "pyright" },
    },
  },

  -- LSP config
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = "VeryLazy",
    config = function()
      -- LSP keymaps applied to every LSP-attached buffer
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "gr", vim.lsp.buf.references, "Go to references")
      end

      -- Pyright — Python type checking and diagnostics
      vim.lsp.config.pyright = vim.tbl_deep_extend("force", vim.lsp.config.pyright, {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              diagnosticMode = "workspace",
            },
          },
        },
      })
      vim.lsp.enable("pyright")

      -- Diagnostic display
      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })
    end,
  },

  -- Auto-completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        completion = {
          keyword_length = 3,
        },
        performance = {
          max_view_entries = 8,
        },
        preselect = cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      }
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns.actions")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
      end,
    },
  },

  -- Neogit — git porcelain in a buffer
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",  -- optional: enhanced diff/log views
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>",               desc = "Neogit status" },
      { "<leader>gc", "<cmd>Neogit commit<CR>",        desc = "Neogit commit" },
      { "<leader>gl", "<cmd>Neogit log<CR>",           desc = "Neogit log" },
      { "<leader>gp", "<cmd>Neogit pull<CR>",          desc = "Neogit pull" },
      { "<leader>gP", "<cmd>Neogit push<CR>",          desc = "Neogit push" },
    },
    opts = {},
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle line" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle block" },
    },
    opts = {},
  },

  -- Markdown render (inline)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md" },
    opts = {},
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "auto" },
    },
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    keys = { "ys", "cs", "ds" },
    opts = {},
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {},
  },
})

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Keep cursor centered when navigating search results
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result centered" })
vim.keymap.set("n", "*", "*zz", { desc = "Word search centered" })
vim.keymap.set("n", "#", "#zz", { desc = "Word search centered" })

-- Clear search highlight
vim.keymap.set("n", "<C-n>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Visual mode: keep selection after indent
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Visual mode: move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Visual mode: paste without yanking replaced text
vim.keymap.set("x", "p", "\"_dP", { desc = "Paste without yanking" })

-- Quick save / close
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Close window" })

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>D", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Python runner
local function find_project_root()
  local markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg" }
  local dir = vim.fn.expand("%:p:h")
  for _ = 1, 10 do
    for _, marker in ipairs(markers) do
      local path = dir .. "/" .. marker
      if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
        return dir
      end
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end
  return nil
end

local function find_venv_python(project_root)
  for _, venv in ipairs({ ".venv", "venv", "env", ".env" }) do
    local py = project_root .. "/" .. venv .. "/bin/python"
    if vim.fn.executable(py) == 1 then
      return py
    end
  end
  return nil
end

local function get_python()
  local project_root = find_project_root()
  if project_root then
    local venv_python = find_venv_python(project_root)
    if venv_python then return venv_python end
  end
  return vim.fn.executable("python3") == 1 and "python3" or "python3"
end

vim.keymap.set("n", "<F5>", function()
  local py = get_python()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end
  vim.cmd("w")
  vim.cmd("!" .. py .. " " .. vim.fn.shellescape(file))
end, { desc = "Run current Python file" })

-- Ruff format on save for Python files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("PythonFormat", { clear = true }),
  pattern = "*.py",
  callback = function()
    if vim.fn.executable("ruff") == 0 then return end
    local view = vim.fn.winsaveview()
    local buf = vim.api.nvim_get_current_buf()
    local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    local formatted = vim.fn.system("ruff format --quiet -", content)
    if vim.v.shell_error == 0 then
      local lines = vim.split(formatted, "\n")
      if #lines > 0 and lines[#lines] == "" then
        table.remove(lines)
      end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.fn.winrestview(view)
    end
  end,
})
