local function gh(repo)
  return "https://github.com/" .. repo
end
vim.pack.add({
  gh("j-hui/fidget.nvim"), -- Useful status updates for LSP.
  gh("neovim/nvim-lspconfig"),
})
require("fidget").setup({})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("zjom-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    -- Rename the variable under your cursor
    --  Most Language Servers support renaming across files, etc.
    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a fn is defined, etc.
    --  To jump back, press <C-T>.
    map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [d]efinition")

    --  This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header
    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    -- Find references for the word under your cursor.
    map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto  [T]ype Definition")

    -- Fuzzy find all the symbols in your current document.
    --  Symbols are things like variables, functions, types, etc.
    map("gO", require("telescope.builtin").lsp_document_symbols, "[O]pen Document Symbols")

    -- Fuzzy find all the symbols in your current workspace
    --  Similar to document symbols, except searches over your whole project.
    map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open [W]orkspace Symbols")

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

    map("<leader>e", vim.diagnostic.open_float, "[E]xpand Diagnositic")

    -- Opens a popup that displays documentation about the word under your cursor
    --  See `:help K` for why this keymap
    map("K", vim.lsp.buf.hover, "Hover Documentation")

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup("zjom-lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("zjom-lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "zjom-lsp-highlight", buffer = event2.buf })
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
      if client.server_capabilities.codeLensProvider then
        vim.lsp.codelens.enable(true)
      end
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map("<leader>xh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "Toggle Inlay [H]ints")
    end
  end,
})

-- LSPs and related tools are installed declaratively via Nix (see
-- nix/home.nix), not mason. This table only tracks which of the
-- nix-installed language tools should be enabled as LSP servers.
--
-- To install a tool: add the matching package to nix/home.nix, then
-- `rebuild`.
-- To enable a tool that's installed but has no LSP server (e.g. a
-- formatter-only tool), set `no_enable = true`.
--
-- To manage lspconfig: update `nvim/lsp/<server>.lua`
-- To override lspconfig options: update `nvim/after/lsp/<server>.lua`
-- See `:help lsp-config-merge`
local tools = {
  -- basedpyright = {},
  clangd = {},
  -- svelte = {},
  -- csharpier = { no_enable = true }, -- C# formatting,
  -- cssls = {},
  -- dprint = { no_enable = true }, -- General purpose formatting
  -- elixirls = {},
  -- emmet_ls = {},
  -- eslint = {}, -- JavaScript and TypeScript linting
  -- gopls = {},
  -- ["google-java-format"] = { no_enable = true },
  -- html = {},
  -- jdtls = {},
  -- lua_ls = {},
  -- marksman = {},
  -- ocamllsp = {},
  -- prettier = { no_enable = true }, -- Web formatting
  -- ruff = {}, -- Python linting & formatting
  rust_analyzer = {},
  zls = {}
  -- sleek = { no_enable = true }, -- SQL formatting
  -- tailwindcss = {},
  -- tinymist = {},
  -- ts_ls = {},
  -- typstyle = { no_enable = true }, --Typst formatting
  -- xmlformatter = { no_enable = true }, -- Xml formatting
}

local servers_to_enable = {}
for tool_name, config in pairs(tools) do
  if not config.no_enable then
    table.insert(servers_to_enable, tool_name)
  end
end

vim.lsp.enable(servers_to_enable)
