local M = {}

-- Helper functions for setting keymaps in each mode
local map = function(mode, keys, func, opts)
  vim.keymap.set(mode, keys, func, opts)
end

local nmap = function(keys, func, opts)
  map("n", keys, func, opts)
end

local tmap = function(keys, func, opts)
  map("t", keys, func, opts)
end

M.setup = function()
  -- Disable space in normal/visual so it can be used as leader
  map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

  -- Navigate by visual lines when no count is given (respects word wrap)
  nmap("k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  nmap("j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

  -- [[ Telescope ]]

  -- Find recently opened files
  nmap("<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
  -- Find open buffers
  nmap("<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
  -- Fuzzy search within the current buffer
  nmap("<leader>/", function()
    require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end, { desc = "[/] Fuzzily search in current buffer" })

  -- File search
  nmap("<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
  nmap("<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
  nmap("<leader>si", function()
    require("telescope.builtin").find_files({ cwd = "./ios" })
  end, { desc = "[S]earch [i]OS files" })

  -- Content search
  nmap("<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
  nmap("<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
  nmap("<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
  nmap("<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })

  -- Git via telescope
  nmap("<leader>gst", require("telescope.builtin").git_status, { desc = "[G]it [S][T]atus" })
  nmap("<leader>gbc", require("telescope.builtin").git_bcommits, { desc = "[G]it [B]uffer [C]ommits" })

  -- [[ Sessions (persisted.nvim) ]]

  require("telescope").load_extension("persisted")
  -- Browse saved sessions
  nmap("<leader>s?", "<Cmd>Telescope persisted<CR>", { desc = "[?] Find [S]essions" })
  -- Stop tracking the current session
  nmap("<leader>ss", "<Cmd>Persisted stop<CR>", { desc = "[S]ession [S]top" })
  -- Load the session for the current directory
  nmap("<leader>sl", "<Cmd>Persisted load<CR>", { desc = "[S]ession [L]oad" })
  -- Delete the session for the current directory
  nmap("<leader>s<C-d>", "<Cmd>Persisted delete<CR>", { desc = "[S]ession [D]elete" })

  -- [[ Diffview ]]

  -- Open diff view for the working tree
  nmap("<leader>do", "<Cmd>DiffviewOpen<CR>", { desc = "[D]iffview [O]pen" })
  -- Close the diff view
  nmap("<leader>dc", "<Cmd>DiffviewClose<CR>", { desc = "[D]iffview [C]lose" })

  -- [[ ToggleTerm ]]

  -- Open a vertical terminal split
  nmap("<leader>te", "<Cmd>ToggleTerm size=100 direction=vertical name=toggleterm<CR>", { desc = "Toggle [T][E]rminal" })

  -- Terminal mode mappings: leader+escape exits terminal mode, C-w switches windows
  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
      local opts = { buffer = 0 }
      tmap("<leader><esc>", [[<C-\><C-n>]], opts)
      tmap("<C-w>", [[<C-\><C-n><C-w>]], opts)
    end,
  })

  -- [[ Trouble (diagnostics) ]]

  -- Toggle the full diagnostics panel
  nmap("<leader>tt", "<Cmd>Trouble diagnostics toggle<CR>", { desc = "[T]rouble [T]oggle" })
  -- Toggle diagnostics scoped to the current buffer
  nmap("<leader>tw", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "[T]rouble [W]indow" })
  -- Open quickfix list in Trouble
  nmap("<leader>tq", "<Cmd>Trouble quickfix<CR>", { desc = "[T]rouble [Q]uickfix" })
  -- Jump to the next trouble item
  nmap("<leader>tn", function()
    require("trouble").next({ skip_groups = true, jump = true })
  end, { desc = "[T]rouble [N]ext" })
  -- Jump to the previous trouble item
  nmap("<leader>tp", function()
    require("trouble").prev({ skip_groups = true, jump = true })
  end, { desc = "[T]rouble [P]revious" })

  -- [[ Neo-tree ]]

  -- Open the filesystem explorer
  nmap("<leader>tf", "<Cmd>Neotree filesystem<CR>", { desc = "Neo[T]ree [F]ilesystem" })
  -- Open the git status panel
  nmap("<leader>tg", "<Cmd>Neotree git_status<CR>", { desc = "Neo[T]ree [G]it Status" })
  -- Open the buffer list panel
  nmap("<leader>tb", "<Cmd>Neotree buffers<CR>", { desc = "Neo[T]ree [B]uffers" })

  -- [[ Neovide clipboard support ]]
  -- https://neovide.dev/faq.html?highlight=paste#how-can-i-use-cmd-ccmd-v-to-copy-and-paste

  if vim.g.neovide then
    -- Cmd+S to save
    nmap("<D-s>", ":w<CR>")
    -- Cmd+C to copy selection
    map("v", "<D-c>", '"+y')
    -- Cmd+V to paste in all modes
    nmap("<D-v>", '"+P')
    map("v", "<D-v>", '"+P')
    map("c", "<D-v>", "<C-R>+")
    map("i", "<D-v>", '<ESC>l"+Pli')
  end

  -- Cmd+V clipboard paste for all modes (non-neovide fallback)
  map("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
  map("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  tmap("<D-v>", "<C-R>+", { noremap = true, silent = true })
  map("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
end

-- [[ LSP keymaps (attached per buffer) ]]

M.setLspMaps = function(_, bufnr)
  local nmapLSP = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    nmap(keys, func, { buffer = bufnr, desc = desc })
  end

  -- Refactoring
  nmapLSP("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmapLSP("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  -- Navigation
  nmapLSP("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmapLSP("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmapLSP("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmapLSP("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

  -- Symbols
  nmapLSP("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmapLSP("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmapLSP("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

  -- Documentation (see `:help K`)
  nmapLSP("K", vim.lsp.buf.hover, "Hover Documentation")
  nmapLSP("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Workspace folder management
  nmapLSP("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmapLSP("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmapLSP("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")
end

-- [[ Git Signs keymaps (attached per buffer) ]]

M.setGitSignsMaps = function(bufnr)
  -- Jump to the previous hunk
  nmap("<leader>gp", require("gitsigns").prev_hunk, { buffer = bufnr, desc = "[G]o to [P]revious Hunk" })
  -- Jump to the next hunk
  nmap("<leader>gn", require("gitsigns").next_hunk, { buffer = bufnr, desc = "[G]o to [N]ext Hunk" })
  -- Preview the hunk under the cursor
  nmap("<leader>ph", require("gitsigns").preview_hunk, { buffer = bufnr, desc = "[P]review [H]unk" })
end

return M
