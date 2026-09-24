local diagnostic_group = vim.api.nvim_create_augroup("RoslynDiagnostics", { clear = true })
local refresh_generation = {}

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
