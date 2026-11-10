-- Python nav/types (Pylance-equivalent). Uses project's .venv (xplat: `uv sync`).
return {
  before_init = function(_, config)
    local py = config.root_dir and (config.root_dir .. "/.venv/bin/python")
    if py and vim.uv.fs_stat(py) then
      config.settings.python = vim.tbl_extend("force", config.settings.python or {}, { pythonPath = py })
    end
  end,
  on_attach = function(_, bufnr)
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) -- inline inferred types; toggle <leader>th
  end,
  settings = {
    basedpyright = {
      -- ruff handles imports/lint
      disableOrganizeImports = true,
      analysis = {
        typeCheckingMode = "standard", -- "recommended" default too noisy; mypy is source of truth
        diagnosticMode = "openFilesOnly",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = false,
        },
        -- mirror xplat.code-workspace python.analysis.exclude
        exclude = {
          ".venv",
          "**/__pycache__",
          "**/.*",
          "**/*.xcodeproj",
          "**/bazel-*",
          "**/external",
          "**/node_modules",
          "**/build",
        },
      },
    },
  },
}
