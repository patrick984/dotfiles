return {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyrightconfig.json",
        "pyproject.toml",
        "uv.lock",
        "poetry.lock",
        "Pipfile",
        "setup.py",
        "requirements.txt",
        ".git",
    },
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "standard",
                diagnosticMode = "workspace",
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                },
            },
        },
    },
}
