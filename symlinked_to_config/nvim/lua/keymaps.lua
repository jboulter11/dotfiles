local M = {}

local nmap = function(keys, func, opts)
  vim.keymap.set("n", keys, func, opts)
end


M.setup = function ()
  -- [[ Basic Keymaps ]]

  -- Keymaps for better default experience
  -- See `:help vim.keymap.set()`
  vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

  -- Remap for dealing with word wrap
  nmap("k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  nmap("j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

  -- See `:help telescope.builtin`
  nmap("<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
  nmap("<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
  nmap("<leader>/", function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = "[/] Fuzzily search in current buffer" })

  nmap("<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
  nmap("<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
  nmap("<leader>si", function() require("telescope.builtin").find_files({ cwd = "./ios" }) end, { desc = "[S]earch [i]OS files" })
  nmap("<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
  nmap("<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
  nmap("<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
  nmap("<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
  nmap("<leader>gst", require("telescope.builtin").git_status, { desc = "[G]it [S][T]atus" })
  nmap("<leader>gbc", require("telescope.builtin").git_bcommits, { desc = "[G]it [B]uffer [C]ommits" })

  -- persisted.nvim configuration
  require("telescope").load_extension("persisted")
  nmap("<leader>s?", "<Cmd>Telescope persisted<CR>", { desc = "[?] Find [S]essions" })
  nmap("<leader>ss", "<Cmd>SessionStop<CR>", { desc = "[S]ession [S]top" })
  nmap("<leader>sl", "<Cmd>SessionLoad<CR>", { desc = "[S]ession [L]oad" })
  nmap("<leader>s<C-d>", "<Cmd>SessionDelete<CR>", { desc = "[S]ession [D]elete" })

  -- Diffview keymaps
  nmap("<leader>do", "<Cmd>DiffviewOpen<CR>", { desc = "[D]iffview [O]pen" })
  nmap("<leader>dc", "<Cmd>DiffviewClose<CR>", { desc = "[D]iffview [C]lose" })

  -- ToggleTerm keymaps
  nmap("<leader>te", "<Cmd>ToggleTerm size=100 direction=vertical name=toggleterm<CR>", { desc = "Toggle [T][E]rminal" })
  function _G.set_terminal_keymaps()
    local opts = {buffer = 0}
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
  end

  -- if you only want these mappings for toggle term use term://*toggleterm#* instead
  vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

  -- Diagnostic keymaps
  -- nmap("[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
  -- nmap("]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
  -- nmap("<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
  -- nmap("<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
  nmap("<leader>tt", "<Cmd>Trouble diagnostics toggle<CR>", { desc = "[T]rouble [T]oggle" })
  nmap("<leader>tw", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "[T]rouble [T]oggle" })
  nmap("<leader>tq", "<Cmd>Trouble quickfix<CR>", { desc = "[T]rouble [Q]uickfix" })
  nmap("<leader>tn", function() require("trouble").next({skip_groups = true, jump = true }) end, { desc = "[T]rouble [N]ext" })
  nmap("<leader>tp", function() require("trouble").next({skip_groups = true, jump = true }) end, { desc = "[T]rouble [P]revious" })

  -- [[ Configure neo-tree ]]
  -- See `:help neo-tree`

  nmap("<leader>tf", "<Cmd>Neotree filesystem<CR>", { desc = "Neo[T]ree [F]ilesystem" })
  nmap("<leader>tg", "<Cmd>Neotree git_status<CR>", { desc = "Neo[T]ree [G]it Status" })
  nmap("<leader>tb", "<Cmd>Neotree buffers<CR>", { desc = "Neo[T]ree [B]uffers" })

  -- [[ claude-code.nvim ]]
  nmap("<leader>cc", "<Cmd>ClaudeCode<CR>", { desc = "Toggle [C]laude [C]ode" })
end

M.setLspMaps = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don"t have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmapLSP = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    nmap(keys, func, { buffer = bufnr, desc = desc })
  end

  nmapLSP("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmapLSP("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmapLSP("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmapLSP("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmapLSP("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmapLSP("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmapLSP("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmapLSP("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

  -- See `:help K` for why this keymap
  nmapLSP("K", vim.lsp.buf.hover, "Hover Documentation")
  nmapLSP("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  nmapLSP("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmapLSP("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmapLSP("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmapLSP("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")
end

M.setGitSignsMaps = function(bufnr)
  nmap("<leader>gp", require("gitsigns").prev_hunk, { buffer = bufnr, desc = "[G]o to [P]revious Hunk" })
  nmap("<leader>gn", require("gitsigns").next_hunk, { buffer = bufnr, desc = "[G]o to [N]ext Hunk" })
  nmap("<leader>ph", require("gitsigns").preview_hunk, { buffer = bufnr, desc = "[P]review [H]unk" })
end

return M
