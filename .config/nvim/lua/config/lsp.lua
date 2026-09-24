vim.lsp.config("*", {
    root_markers = {
        {
            "Cargo.toml",
            "go.mod",
            "package.json",
            "pyproject.toml",
            "compile_commands.json",
        },
        ".git",
    },
})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

vim.opt.completeopt = { "menuone", "noselect", "popup" }

local diagnostic_popup_group = vim.api.nvim_create_augroup("DiagnosticPopup", { clear = true })

local diagnostic_severity_names = {
    [vim.diagnostic.severity.ERROR] = "Error",
    [vim.diagnostic.severity.WARN] = "Warning",
    [vim.diagnostic.severity.INFO] = "Info",
    [vim.diagnostic.severity.HINT] = "Hint",
}

local function show_line_diagnostics()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

    if #diagnostics == 0 then
        return
    end

    table.sort(diagnostics, function(left, right)
        if left.severity ~= right.severity then
            return left.severity < right.severity
        end
        return (left.col or 0) < (right.col or 0)
    end)

    local seen = {}
    local contents = {}

    for _, diagnostic in ipairs(diagnostics) do
        local key = table.concat({
            diagnostic.message,
            tostring(diagnostic.severity),
            tostring(diagnostic.code),
            tostring(diagnostic.lnum),
            tostring(diagnostic.col),
            tostring(diagnostic.end_lnum),
            tostring(diagnostic.end_col),
        }, "\0")

        if not seen[key] then
            seen[key] = true

            if #contents > 0 then
                table.insert(contents, "")
            end

            local severity = diagnostic_severity_names[diagnostic.severity] or "Diagnostic"
            local metadata = {}
            if diagnostic.source and diagnostic.source ~= "" then
                table.insert(metadata, diagnostic.source)
            end
            if diagnostic.code ~= nil then
                table.insert(metadata, tostring(diagnostic.code))
            end

            local message_lines = vim.split(diagnostic.message, "\n", { plain = true })
            local suffix = #metadata > 0 and " (" .. table.concat(metadata, ", ") .. ")" or ""
            message_lines[1] = severity .. ": " .. message_lines[1]
            message_lines[#message_lines] = message_lines[#message_lines] .. suffix
            vim.list_extend(contents, message_lines)
        end
    end

    local max_width = math.max(20, math.min(100, vim.o.columns - 4))
    vim.lsp.util.open_floating_preview(contents, "plaintext", {
        border = "single",
        focusable = false,
        max_width = max_width,
        max_height = math.max(4, math.floor(vim.o.lines * 0.4)),
        wrap = true,
        wrap_at = max_width,
        close_events = { "BufHidden", "CursorMoved", "InsertEnter" },
    })
end

vim.api.nvim_create_autocmd("CursorHold", {
    group = diagnostic_popup_group,
    callback = show_line_diagnostics,
    desc = "Show diagnostics for the current line",
})

vim.keymap.set("n", "<leader>cd", show_line_diagnostics, {
    desc = "Show line diagnostics",
})

local format_sync_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

-- Formatting is opt-in per language. Add a filetype here when you want it.
local format_on_save_filetypes = {
    cs = true,
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

        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, bufnr, {
                autotrigger = true,
            })
        end

        if client:supports_method("textDocument/inlayHint") then
            local delay = client.name == "clangd" and 150 or 0

            vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end, delay)
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
            { buffer = bufnr, desc = "Go to declaration" })
        vim.keymap.set("n", "<leader>cs", vim.lsp.buf.workspace_symbol, opts)
        if client.name == "clangd" then
            vim.keymap.set("n", "<leader>cc", function()
                local method = "textDocument/switchSourceHeader"
                if not client:supports_method(method) then
                    vim.notify("clangd does not support source/header switching", vim.log.levels.WARN)
                    return
                end

                local params = vim.lsp.util.make_text_document_params(bufnr)
                client:request(method, params, function(err, result)
                    if err then
                        vim.notify(err.message or tostring(err), vim.log.levels.ERROR)
                    elseif not result or result == "" then
                        vim.notify("No corresponding source/header file found", vim.log.levels.INFO)
                    else
                        vim.schedule(function()
                            vim.cmd.edit(vim.fn.fnameescape(vim.uri_to_fname(result)))
                        end)
                    end
                end, bufnr)
            end, { buffer = bufnr, desc = "Switch Source/Header" })
        end
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

-- Server definitions live in lsp/<name>.lua and are discovered from runtimepath.
vim.lsp.enable({
    "clangd",
    "cssls",
    "gopls",
    "html",
    "jsonls",
    "ols",
    "pyright",
    "roslyn",
    "rust_analyzer",
    "vtsls",
})
