-- Lint/format/organize imports. Reads pyproject.toml [tool.ruff].
return {
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false -- defer hover to basedpyright
  end,
}
