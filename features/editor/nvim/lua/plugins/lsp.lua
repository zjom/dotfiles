local function gh(repo)
  return "https://github.com/" .. repo
end
vim.pack.add({
  gh("j-hui/fidget.nvim"), -- Shows the status updates of the LSP servers.
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

    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [d]efinition")

    map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

    map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

    map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto  [T]ype Definition")

    map("gO", require("telescope.builtin").lsp_document_symbols, "[O]pen Document Symbols")

    map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open [W]orkspace Symbols")

    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

    map("<leader>e", vim.diagnostic.open_float, "[E]xpand Diagnositic")

    map("K", vim.lsp.buf.hover, "Hover Documentation")

    -- The two autocommands that follow highlight the references to the word
    -- under the cursor when the cursor stays on the word for a short time. See
    -- `:help CursorHold` for the time when this autocommand runs.
    --
    -- When the cursor moves, the second autocommand clears the highlights.
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

-- Nix installs the LSP servers and the related tools declaratively (see shells/
-- and features/base/packages.nix). To change the lspconfig configuration of a
-- server, edit `nvim/lsp/<server>.lua`. To override the lspconfig options of a
-- server, edit `nvim/after/lsp/<server>.lua`. See `:help lsp-config-merge`.
local servers = {
  "ty",
  "clangd",
  "cssls",
  "elixirls",
  "emmet_ls",
  "eslint",
  "gopls",
  "html",
  "jdtls",
  "just",
  "lua_ls",
  "marksman",
  "nixd",
  "ocamllsp",
  "oxlint",
  "ruff",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "tinymist",
  "tofu_ls",
  "tombi",
  "ts_ls",
  "zls",
}

vim.lsp.enable(servers)
