local diagnostic_group = vim.api.nvim_create_augroup("RoslynDiagnostics", { clear = true })
local refresh_generation = {}
local definition_namespace = vim.api.nvim_create_namespace("RoslynMethodDefinitions")
local definition_refresh_generation = {}

local definition_kinds = {
    [vim.lsp.protocol.SymbolKind.Function] = true,
    [vim.lsp.protocol.SymbolKind.Method] = true,
    [vim.lsp.protocol.SymbolKind.Constructor] = true,
}

local function refresh_method_definitions(client, bufnr)
    client:request("textDocument/documentSymbol", {
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
    }, function(err, symbols)
        if err or not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end

        vim.api.nvim_buf_clear_namespace(bufnr, definition_namespace, 0, -1)

        local function add_symbols(items)
            for _, symbol in ipairs(items or {}) do
                if definition_kinds[symbol.kind] and symbol.selectionRange then
                    local range = symbol.selectionRange
                    local line = vim.api.nvim_buf_get_lines(
                        bufnr, range.start.line, range.start.line + 1, false
                    )[1] or ""
                    local start_col = vim.str_byteindex(
                        line, client.offset_encoding, range.start.character, false
                    )
                    local end_col = vim.str_byteindex(
                        line, client.offset_encoding, range["end"].character, false
                    )

                    vim.api.nvim_buf_set_extmark(bufnr, definition_namespace, range.start.line,
                        start_col, {
                            end_row = range["end"].line,
                            end_col = end_col,
                            hl_group = "CSharpMethodDefinition",
                            priority = 130,
                        })
                end
                add_symbols(symbol.children)
            end
        end

        add_symbols(symbols)
    end, bufnr)
end

local function schedule_definition_refresh(client, bufnr)
    local generation = (definition_refresh_generation[bufnr] or 0) + 1
    definition_refresh_generation[bufnr] = generation

    vim.defer_fn(function()
        if definition_refresh_generation[bufnr] == generation
            and vim.api.nvim_buf_is_valid(bufnr) then
            refresh_method_definitions(client, bufnr)
        end
    end, 200)
end

local function refresh_diagnostics(client, target_bufnr)
    local registrations = client.dynamic_capabilities.capabilities.diagnosticProvider or {}

    local function refresh_buffer(bufnr)
        if not vim.api.nvim_buf_is_loaded(bufnr) then
            return
        end

        for _, registration in pairs(registrations) do
            local options = registration.registerOptions or {}
            client:request("textDocument/diagnostic", {
                identifier = options.identifier,
                textDocument = vim.lsp.util.make_text_document_params(bufnr),
            }, nil, bufnr)
        end
    end

    if target_bufnr then
        if client.attached_buffers[target_bufnr] then
            refresh_buffer(target_bufnr)
        end
        return
    end

    for bufnr in pairs(client.attached_buffers) do
        refresh_buffer(bufnr)
    end
end

local function schedule_refresh(client, bufnr)
    local generation = (refresh_generation[bufnr] or 0) + 1
    refresh_generation[bufnr] = generation

    vim.defer_fn(function()
        if refresh_generation[bufnr] ~= generation
            or not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end
        refresh_diagnostics(client, bufnr)
    end, 200)
end

return {
    cmd = { "roslyn-language-server", "--stdio" },
    filetypes = { "cs" },
    root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, function(name)
            return name:match("%.slnx?$") ~= nil
        end)
        if not root then
            root = vim.fs.root(bufnr, function(name)
                return name:match("%.csproj$") ~= nil
            end)
        end
        if root then
            on_dir(root)
        end
    end,
    capabilities = {
        textDocument = { diagnostic = { dynamicRegistration = true } },
    },
    on_init = function(client)
        local root = client.root_dir
        if not root then return end

        local projects = {}
        for name, kind in vim.fs.dir(root) do
            if kind == "file" and (vim.endswith(name, ".sln") or vim.endswith(name, ".slnx")) then
                client:notify("solution/open", {
                    solution = vim.uri_from_fname(vim.fs.joinpath(root, name)),
                })
                return
            elseif kind == "file" and vim.endswith(name, ".csproj") then
                table.insert(projects, vim.uri_from_fname(vim.fs.joinpath(root, name)))
            end
        end

        if #projects > 0 then
            client:notify("project/open", { projects = projects })
        end
    end,
    handlers = {
        ["workspace/projectInitializationComplete"] = function(_, _, ctx)
            local client = vim.lsp.get_client_by_id(ctx.client_id)
            if client then
                refresh_diagnostics(client)
            end
            return vim.NIL
        end,
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_clear_autocmds({ group = diagnostic_group, buffer = bufnr })
        if client:supports_method("textDocument/documentSymbol") then
            schedule_definition_refresh(client, bufnr)
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
                group = diagnostic_group,
                buffer = bufnr,
                callback = function()
                    schedule_definition_refresh(client, bufnr)
                end,
                desc = "Highlight C# method definitions",
            })
        end

        if client:supports_method("textDocument/signatureHelp") then
            vim.api.nvim_create_autocmd("InsertCharPre", {
                group = diagnostic_group,
                buffer = bufnr,
                callback = function()
                    if vim.v.char ~= "(" and vim.v.char ~= "," then
                        return
                    end

                    vim.schedule(function()
                        if vim.api.nvim_get_current_buf() == bufnr
                            and vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
                            vim.lsp.buf.signature_help({
                                border = "single",
                                focusable = false,
                                silent = true,
                            })
                        end
                    end)
                end,
                desc = "Show Roslyn signature help in argument lists",
            })
        end

        vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
            group = diagnostic_group,
            buffer = bufnr,
            callback = function()
                refresh_generation[bufnr] = (refresh_generation[bufnr] or 0) + 1
                refresh_diagnostics(client, bufnr)
            end,
            desc = "Refresh Roslyn diagnostics",
        })
        vim.api.nvim_create_autocmd("TextChanged", {
            group = diagnostic_group,
            buffer = bufnr,
            callback = function()
                schedule_refresh(client, bufnr)
            end,
            desc = "Refresh Roslyn diagnostics after normal-mode edits",
        })
        vim.api.nvim_create_autocmd("BufWipeout", {
            group = diagnostic_group,
            buffer = bufnr,
            callback = function()
                refresh_generation[bufnr] = nil
                definition_refresh_generation[bufnr] = nil
            end,
            desc = "Clear Roslyn diagnostic refresh state",
        })
    end,
    settings = {
        ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
        },
    },
}
