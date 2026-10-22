return {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "ruff.toml",
        ".ruff.toml",
        "uv.lock",
        "poetry.lock",
        "Pipfile",
        "requirements.txt",
        ".git",
    },
    init_options = {
        settings = {
            configurationPreference = "filesystemFirst",
        },
    },
    on_attach = function(client)
        -- BasedPyright provides the richer Python hover information.
        client.server_capabilities.hoverProvider = false
    end,
}
