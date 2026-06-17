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
vim.opt.hidden = true
vim.opt.updatetime = 250
vim.opt.tabstop = 4
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.termguicolors = true
vim.g.netrw_winsize = 30
vim.g.netrw_altv = 1

-- Enable deep native project file discovery
vim.opt.path:append("**")          -- Search recursively down through all subdirectories
vim.opt.wildignore:append({ "**/.DS_Store", "**/node_modules/**", "**/.git/**", "**/.cache/**", "**/target/**", "**/bin/**", "**/obj/**" }) -- Skip heavy folders
vim.opt.wildmode = "longest:full,full" -- Smooth Tab completion behavior in the command line

-- Buffer navigation in Normal Mode
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true, desc = "Previous buffer" })

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


-- Native omnifunc completion using <Tab>
vim.keymap.set("i", "<Tab>", function()
    -- If completion popup is visible, select next item
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    end

    -- Respect literal tab at start of line
    local col = vim.fn.col(".") - 1
    if col == 0 then
        return vim.api.nvim_replace_termcodes(
            "<Tab>", true, true, true
        )
    end

    -- Character immediately before cursor
    local line = vim.fn.getline(".")
    local prev = line:sub(col, col)

    local should_complete =
        prev:match("[%w_]")  -- identifiers
        or prev:match("[.:>]") -- member access

    if should_complete and vim.bo.omnifunc ~= "" then
        return "<C-x><C-o>"
    end

    -- Fallback: normal tab insertion/indentation
    return vim.api.nvim_replace_termcodes( "<Tab>", true, true, true)
end,
{ expr = true, noremap = true, desc = "LSP omnifunc completion" })

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

-- GUI cursor config
vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25-iCursor,r-cr-o:hor20'
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


-- ========================================================================== --
-- 4. LSP Configuration
-- ========================================================================== --
vim.lsp.config("*", {
    root_markers = {
        ".git",
        "Cargo.toml",
        "go.mod",
        "package.json",
        "pyproject.toml",
        "compile_commands.json",
        "*.sln",
        "*.csproj",
    },
})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

local format_sync_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

-- Formatting is opt-in per language. Add a filetype here when you want it.
local format_on_save_filetypes = {
    -- python = true,
    -- go = true,
    -- rust = true,
    -- typescript = true,
}

-- Handle bindings natively on file capture
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local opts = { buffer = args.buf }

        if not client then return end

        if client:supports_method( "textDocument/inlayHint") then
            local delay = client.name == "clangd" and 150 or 0

            vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end, delay)
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
        vim.keymap.set("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>cc", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch Source/Header" })
        vim.keymap.set("n", "<leader>cf", function()
                vim.lsp.buf.format({ bufnr = bufnr, async = true })
        end, { buffer = bufnr, desc = "Format Document (Manual)" })

        if format_on_save_filetypes[vim.bo[bufnr].filetype]
            and client:supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = format_sync_group, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = format_sync_group,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr, async = false, timeout_ms = 5000,
                        filter = function(c)
                            return c.id == client.id
                        end,
                    })
                end,
            })
        end
    end,
})



-- Type space + t + h ('toggle hints') to instantly clear or show virtual labels
vim.keymap.set("n", "<leader>th", function()
    local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = 0 })
    print("Inlay hints: " .. (not is_enabled and "ON" or "OFF"))
end, { desc = "Toggle Inlay Hints" })

local function enable_lsp_if_available(name, executable, config)
    if vim.fn.executable(executable) ~= 1 then
        return
    end

    vim.lsp.config(name, config)
    vim.lsp.enable(name)
end

-- Define server launch properties statically and enable only installed servers.
enable_lsp_if_available("pyright", "pyright-langserver", {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    settings = {
        python = {
            analysis = {
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                },
            },
        },
    },
})

enable_lsp_if_available("vtsls", "vtsls", {
    cmd = { "vtsls", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    settings = {
        typescript = {
            inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            },
        },
        javascript = {
            inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            },
        },
    },
})

enable_lsp_if_available("ols", "ols", {
    cmd = { "ols" },
    filetypes = { "odin" },
})

enable_lsp_if_available("clangd", "clangd", {
    cmd = { "clangd" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
})

enable_lsp_if_available("rust_analyzer", "rust-analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    settings = {
        ["rust-analyzer"] = {
            inlayHints = {
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true },
                parameterHints = { enable = true },
                typeHints = { enable = true },
            },
        },
    },
})

enable_lsp_if_available("gopls", "gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
})

enable_lsp_if_available("html", "vscode-html-language-server", {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
})

enable_lsp_if_available("cssls", "vscode-css-language-server", {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
})

enable_lsp_if_available("jsonls", "vscode-json-language-server", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
})

enable_lsp_if_available("roslyn", "roslyn-language-server", {
    cmd = { "roslyn-language-server", "--stdio" },
    filetypes = { "cs", "razor" },
    root_markers = { "*.sln", "*.csproj", ".git" },
    settings = {
        ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
        },
    },
})
