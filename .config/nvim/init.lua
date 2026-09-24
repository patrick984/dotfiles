-- ========================================================================== --
-- 1. General Settings
-- ========================================================================== --
vim.g.mapleader = " "
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildignorecase = true
vim.opt.hidden = true
vim.opt.updatetime = 250
vim.opt.tabstop = 4
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.g.netrw_winsize = 30
vim.g.netrw_altv = 1
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

local autosync_group = vim.api.nvim_create_augroup("AutoSaveAndReload", { clear = true })

vim.api.nvim_create_autocmd({ "FocusLost", "VimSuspend" }, {
  group = autosync_group,
  callback = function()
    vim.cmd("wall")
  end,
  desc = "Save modified buffers when leaving Neovim",
})

vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
  group = autosync_group,
  callback = function()
    vim.schedule(function()
      vim.cmd("checktime")
    end)
  end,
  desc = "Reload externally changed files when returning to Neovim",
})

if vim.env.COLORTERM == "truecolor" or vim.env.COLORTERM == "24bit" then
  vim.opt.termguicolors = true
else
  vim.opt.termguicolors = false
end

-- Enable deep native project file discovery
vim.opt.path:append("**")          -- Search recursively down through all subdirectories
vim.opt.wildignore:append({ "**/.DS_Store", "**/node_modules/**", "**/.git/**", "**/.cache/**", "**/target/**", "**/bin/**", "**/obj/**" }) -- Skip heavy folders
vim.opt.wildmode = "longest:full,full" -- Smooth Tab completion behavior in the command line

-- Split navigation
vim.keymap.set("n", "<leader>e", "<cmd>Lex!<CR>", { silent = true, desc = "Open file explorer"})

vim.keymap.set("n", "<leader>h", ":wincmd h<CR>", { silent = true, desc = "Nav split left"})
vim.keymap.set("n", "<leader>j", ":wincmd j<CR>", { silent = true, desc = "Nav split below"})
vim.keymap.set("n", "<leader>k", ":wincmd k<CR>", { silent = true, desc = "Nav split above"})
vim.keymap.set("n", "<leader>l", ":wincmd l<CR>", { silent = true, desc = "Nav split right"})

vim.keymap.set("n", "<leader><left>", ":wincmd H<CR>", { silent = true, desc = "Nav split left"})
vim.keymap.set("n", "<leader><down>", ":wincmd J<CR>", { silent = true, desc = "Nav split below"})
vim.keymap.set("n", "<leader><up>", ":wincmd K<CR>", { silent = true, desc = "Nav split above"})
vim.keymap.set("n", "<leader><right>", ":wincmd L<CR>", { silent = true, desc = "Nav split right"})

-- Quick find file anywhere under the current working directory
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find file in project" })

-- Quick find buffer (search through your currently open files by name)
vim.keymap.set("n", "<leader>fb", ":buffer ", { desc = "Find active buffer" })


-- Navigate native LSP completion with <Tab>; completion itself is asynchronous.
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    end
    return "<Tab>"
end,
{ expr = true, noremap = true, desc = "Next completion item or insert tab" })

vim.keymap.set("i", "<C-Space>", function()
    local completion = vim.fn.complete_info({ "selected" })
    if vim.fn.pumvisible() == 1 and completion.selected == -1 then
        vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local attempts = 0
    local function select_first_result()
        if vim.api.nvim_get_current_buf() ~= bufnr
            or vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
            return
        end

        if vim.fn.pumvisible() == 1 then
            if vim.fn.complete_info({ "selected" }).selected == -1 then
                vim.api.nvim_input(vim.keycode("<C-n>"))
            end
            return
        end

        attempts = attempts + 1
        if attempts < 100 then
            vim.defer_fn(select_first_result, 10)
        end
    end

    vim.lsp.completion.get()
    vim.defer_fn(select_first_result, 10)
end, { desc = "Trigger LSP completion and select first item" })

-- Close popups
vim.keymap.set('n', '<leader>x', function()
  -- 1. Close Quickfix and Location lists
  vim.cmd('cclose')
  vim.cmd('lclose')

  -- 2. Close all floating/popup windows (LSP hover, diagnostics, etc.)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = "Close quickfix, loclist, and popup windows" })

-- ========================================================================== --
-- 2. Custom colour scheme
-- ========================================================================== --
vim.opt.background = "light"
vim.g.colors_name = "light_custom"

-- Clear existing highlights natively
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

-- Terminal ANSI colors definitions
vim.g.terminal_ansi_colors = {
    '#000000', '#A80000', '#007800', '#705000',
    '#0030C0', '#800080', '#006868', '#202020',
    '#555555', '#D80000', '#00A000', '#946C00',
    '#0050FF', '#B000B0', '#009090', '#333333'
}

-- Highlight groups
local hl_groups = {
    -- Base UI
    Title          = { fg = "#7c3c00", bold = true },
    Normal         = { fg = "#000000", bg = "#fffff5" },
    CursorLine     = { bg = "#eef2f5" },
    CursorColumn   = { bg = "#f6f8fa" },
    LineNr         = { fg = "#808080" },
    CursorLineNr   = { fg = "#000000" },
    Visual         = { bg = "#9fdfff" },
    Search         = { bg = "#7dec97" },
    IncSearch      = { bg = "#ffdf5d" },
    CurSearch      = { bg = "#ffdf5d" },
    MatchParen     = { bg = "#dc99df" },
    StatusLine     = { fg = "#000000", bg = "#ebf5ff", bold = true },
    StatusLineNC   = { fg = "#000000", bg = "#ebf5ff" },
    WinSeparator   = { fg = "#ebf5ff", bg = "#ebf5ff" },
    Pmenu          = { fg = "#000000", bg = "#eaffea" },
    PmenuSel       = { fg = "#ffffff", bg = "#558855" },
    PmenuSbar      = { bg = "#e2e2e2" },
    PmenuThumb     = { bg = "#888888" },
    Folded         = { fg = "#4a6fa5", bg = "#dceeff" },
    FoldColumn     = { fg = "#000000" },
    SignColumn     = { fg = "#000000", bg = "NONE" },
    ColorColumn    = { bg = "#eeeeee" },
    ErrorMsg       = { fg = "#ffffff", bg = "#bb5d5d" },
    WarningMsg     = { fg = "#99884c" },
    Conceal        = { fg = "#999999" },

    -- Diff / Git Gutter
    DiffAdd        = { fg = "#000000", bg = "#d4edd9" },
    DiffChange     = { fg = "#000000", bg = "#e1f5fe" },
    DiffDelete     = { fg = "#000000", bg = "#fbe9e7" },

    -- Core Token Syntax Syntax
    Comment        = { fg = "#6b7ca8", italic = true },
    String         = { fg = "#067200" },
    Character      = { fg = "#067200" },
    Number         = { fg = "#0254b2" },
    Float          = { fg = "#0254b2" },
    Keyword        = { fg = "#7b0080" },
    Operator       = { fg = "#7b0080" },
    Statement      = { fg = "#7b0080" },
    Conditional    = { fg = "#7b0080" },
    Repeat         = { fg = "#7b0080" },
    Function       = { fg = "#102c8a" },
    Type           = { fg = "#006974" },
    Identifier     = { fg = "#000000" },
    PreProc        = { fg = "#7c3c00" },
    Include        = { fg = "#7c3c00" },
    Define         = { fg = "#7c3c00" },
    Constant       = { fg = "#7c3c00" },
    Special        = { fg = "#7c3c00" },

    -- Diagnostics
    DiagnosticError = { fg = "#bb5d5d" },
    DiagnosticWarn  = { fg = "#99884c" },
    DiagnosticInfo  = { fg = "#4670bb" },
    DiagnosticHint  = { fg = "#558855" },
    DiagnosticSignError = { fg = "#bb5d5d" },
    DiagnosticSignWarn  = { fg = "#99884c" },
    DiagnosticSignInfo  = { fg = "#4670bb" },
    DiagnosticSignHint  = { fg = "#558855" },
    DiagnosticVirtualTextError = { fg = "#bb5d5d" },
    DiagnosticVirtualTextWarn = { fg = "#99884c" },
    DiagnosticVirtualTextInfo = { fg = "#4670bb" },
    DiagnosticVirtualTextHint = { fg = "#558855" },

    -- Misc elements
    Todo           = { fg = "#d27400", bg = "#f6f8fa", bold = true },
    NonText        = { fg = "#a0a0a0" },
    SpecialKey     = { fg = "#000000" },

    FloatBorder    = { fg = "#558855", bg = "#eaffea" },
}

-- Batch apply the highlighters
for group, settings in pairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, settings)
end

-- Link modern Treesitter nodes back to your defined syntax groups
local link_groups = {
    ["@variable"]      = "Identifier",
    ["@function"]      = "Function",
    ["@type"]          = "Type",
    ["@keyword"]       = "Keyword",
    ["@string"]        = "String",
    ["@comment"]       = "Comment",
    ["@constant"]      = "Constant",
    NormalFloat        = "PMenu",
}

for from, to in pairs(link_groups) do
    vim.api.nvim_set_hl(0, from, { link = to })
end

vim.api.nvim_set_hl(0, "@lsp.typemod.function.definition", { bold = true })
vim.api.nvim_set_hl(0, "@lsp.type.operator", { fg = "#000000" })
-- Let C# syntax groups such as csTodo show through Roslyn's whole-comment token.
vim.api.nvim_set_hl(0, "@lsp.type.comment.cs", {})
vim.api.nvim_set_hl(0, "@lsp.type.recordClass.cs", { link = "Type" })
vim.api.nvim_set_hl(0, "@lsp.type.recordStruct.cs", { link = "Type" })
vim.api.nvim_set_hl(0, "@lsp.type.extensionMethod.cs", { link = "Function" })
vim.api.nvim_set_hl(0, "CSharpMethodDefinition", { bold = true })

-- GUI cursor config
vim.opt.guicursor = 'n-v-c:block-Cursor,i-ci-ve:ver25-iCursor,r-cr-o:hor20'
vim.api.nvim_set_hl(0, "Cursor", { fg = "NONE", bg = "#0366d6" })
vim.api.nvim_set_hl(0, "iCursor", { fg = "NONE", bg = "#DD0000" })

-- Float config
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}

    -- "single" uses thin line borders colored by FloatBorder above.
    -- Change to "none" if you prefer completely borderless floating panels.
    opts.border = opts.border or "single"

    -- Forces the window to use our unified background highlights
    opts.focusable = opts.focusable ~= false

    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Diagnostic popup config
vim.diagnostic.config({
    float = {
        border = "single",
        header = "",
        prefix = "",
        format = function(diagnostic)
            return string.format("%s (%s)", diagnostic.message, diagnostic.source or "LSP")
        end,
    },
})

-- Close current buffer without breaking split window layouts
vim.keymap.set("n", "<leader>bd", function()
    local bd = vim.api.nvim_buf_delete
    local buf = vim.api.nvim_get_current_buf()

    -- If file has unsaved changes, let native Neovim throw the safe warning
    if vim.bo.modified then
        vim.cmd("bdelete")
        return
    end

    -- Switch to next buffer before wiping the current one
    vim.cmd("bnext")
    local new_buf = vim.api.nvim_get_current_buf()

    -- If we didn't actually change buffers (it was the last one open), create an empty scratchpad
    if buf == new_buf then
        vim.cmd("enew")
    end

    -- Safely wipe out the target buffer background array
    pcall(bd, buf, { force = false })
end, { silent = true, desc = "Delete buffer safely" })

-- ========================================================================== --
-- 3. Dynamic Minimalist Statusline
-- ========================================================================== --

vim.opt.showmode = false

-- Define mode-specific color highlights dynamically from your palette
local function update_statusline_hl(mode)
    if mode == 'n' then
        -- Normal Mode: Subtle sky blue background
        vim.api.nvim_set_hl(0, "StatusLineAccent", { fg = "#000000", bg = "#ebf5ff", bold = true })
    elseif mode == 'i' or mode == 'ic' then
        -- Insert Mode: Soft mint green matching your Pmenu
        vim.api.nvim_set_hl(0, "StatusLineAccent", { fg = "#000000", bg = "#eaffea", bold = true })
    elseif mode == 'v' or mode == 'V' or mode == '\22' then
        -- Visual Mode: Soft sky blue matching your selection zone
        vim.api.nvim_set_hl(0, "StatusLineAccent", { fg = "#000000", bg = "#9fdfff", bold = true })
    elseif mode == 'R' or mode == 'Rx' then
        -- Replace Mode: Clean warning tint
        vim.api.nvim_set_hl(0, "StatusLineAccent", { fg = "#ffffff", bg = "#bb5d5d", bold = true })
    else
        -- Command/Other Modes: Fallback to Title accent
        vim.api.nvim_set_hl(0, "StatusLineAccent", { fg = "#ffffff", bg = "#7c3c00", bold = true })
    end
end

-- Human-readable mapping dictionary for active editor states
local mode_map = {
    ['n']  = ' NORMAL ', ['i']  = ' INSERT ', ['v']  = ' VISUAL ',
    ['V']  = ' V-LINE ', ['\22'] = ' V-BLOCK', ['c']  = ' COMMAND',
    ['R']  = ' REPLACE', ['t']  = ' TERMINAL',
}

-- Global structural generation block evaluated on every cursor tick
function _G.render_minimal_statusline()
    local mode = vim.api.nvim_get_mode().mode
    update_statusline_hl(mode)

    local mode_display = mode_map[mode] or ' NORMAL '

    -- Constructing the structural component array:
    -- %#Group# switches colors. %f represents file paths. %m checks modification flags.
    -- %= splits layout alignment to the far right.
    return string.format(
        "%%#StatusLineAccent#%s%%#StatusLine# %%f %%m%%=%%l:%%c  %%P ",
        mode_display
    )
end

-- Activate the layout engine globally across active workspaces
vim.opt.statusline = "%!v:lua.render_minimal_statusline()"

-- Force rendering passes to sync instantly during fast visual selection tracks
vim.api.nvim_create_autocmd({ "ModeChanged" }, {
    pattern = "*",
    callback = function()
        vim.cmd("redrawstatus")
    end,
})


-- Shared LSP behavior and native per-server configurations.
require("config.lsp")
-- ========================================================================== --
-- 1. General Settings
-- ========================================================================== --

local codediff_dir = vim.fn.expand("~/.local/share/nvim/codediff.nvim")

if vim.fn.isdirectory(codediff_dir) then
    vim.opt.rtp:append("~/.local/share/nvim/codediff.nvim")
end

local fzf_dir = vim.fn.expand('~/.config/nvim/pack/plugins/opt/fzf-lua')
local fzf_icons_dir = vim.fn.expand('~/.config/nvim/pack/plugins/opt/nvim-web-devicons')

if vim.fn.isdirectory(fzf_dir) == 1 then
    -- Load the plugins using the built-in package manager
    local fzf_loaded = pcall(vim.cmd, 'packadd fzf-lua')

    if vim.fn.isdirectory(fzf_icons_dir) == 1 then
        pcall(vim.cmd, 'packadd nvim-web-devicons')
    end

    local fzf_ok, fzf_lua = pcall(require, 'fzf-lua')
    if fzf_loaded and fzf_ok then
        local function fzf_project_history(picker)
            local root = vim.fs.root(0, { ".git", ".hg", ".svn" }) or vim.fn.getcwd()
            root = vim.uv.fs_realpath(root) or root
            local project_id = vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 16)
            local history_dir = vim.fn.stdpath("data") .. "/fzf-history/projects/" .. project_id
            vim.fn.mkdir(history_dir, "p")
            return history_dir .. "/" .. picker
        end

        -- Initialize the plugin settings
        fzf_lua.setup({
            fzf_colors = true,
            hls = {
                normal = "Pmenu",
                border = "FloatBorder",
                title = "Title",
                preview_normal = "NormalFloat",
                preview_border = "FloatBorder",
                fzf = {
                    normal = "Pmenu",
                    cursorline = "PmenuSel",
                    match = "Search",
                    border = "FloatBorder",
                    gutter = "Pmenu",
                    prompt = "Special",
                    query = "Pmenu",
                },
            },
            grep = {
                rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e",
            },
        })

        -- Set up keymaps
        local function find_files()
            fzf_lua.files({ fzf_opts = { ["--history"] = fzf_project_history("files") } })
        end

        local function live_grep()
            fzf_lua.live_grep({ fzf_opts = { ["--history"] = fzf_project_history("live-grep") } })
        end

        vim.keymap.set('n', '<c-p>', find_files, { desc = 'Find Files' })
        vim.keymap.set('n', '<leader>ff', find_files, { desc = 'Find Files' })
        vim.keymap.set('n', '<leader>fg', live_grep, { desc = 'Live Grep' })
        vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Buffers' })
    end
end

local fugitive_dir = vim.fn.expand('~/.config/nvim/pack/plugins/opt/vim-fugitive')

if vim.fn.isdirectory(fugitive_dir) == 1 then
    -- Load the plugin via native package manager
    local fugitive_loaded = pcall(vim.cmd, 'packadd vim-fugitive')

    if fugitive_loaded then
        -- Set up basic keymaps for common Git actions
        vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>', { desc = 'Git Status summary' })
        vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<CR>', { desc = 'Git Diff split' })
        vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<CR>', { desc = 'Git Blame' })
    end
end

local diffs_dir = vim.fn.expand('~/.config/nvim/pack/plugins/opt/diffs.nvim')

if vim.fn.isdirectory(diffs_dir) == 1 then
    -- Load the plugin via native package manager
    pcall(vim.cmd, 'packadd diffs.nvim')
end

local grug_far_dir = vim.fn.expand('~/.config/nvim/pack/plugins/opt/grug-far.nvim')

if vim.fn.isdirectory(grug_far_dir) == 1 and vim.fn.executable('rg') == 1 then
    -- grug-far uses ripgrep for project-wide search and replace.
    local grug_far_loaded = pcall(vim.cmd, 'packadd grug-far.nvim')
    local grug_far_ok, grug_far = pcall(require, 'grug-far')

    if grug_far_loaded and grug_far_ok then
        grug_far.setup({
            windowCreationCommand = 'rightbelow vsplit',
            openTargetWindow = {
                preferredLocation = 'prev',
            },
        })

        vim.keymap.set('n', '<leader>sr', grug_far.open, { desc = 'Search and replace' })
        vim.keymap.set('x', '<leader>sr', grug_far.open, { desc = 'Search and replace selection' })
    end
end
