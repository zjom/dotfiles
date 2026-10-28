vim.pack.add({ "https://github.com/stevearc/conform.nvim" })
-- Use conform for gq.
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
-- Enable auto-formatting by default. The ToggleFormat command disables it.
vim.g.autoformat = true
local function format_on_save(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname:match("/node_modules/") then
    return nil
  end

  -- Do not format if the special save command started the save.
  if vim.g.skip_formatting then
    vim.g.skip_formatting = false
    return nil
  end

  if not vim.g.autoformat then
    return nil
  end

  return {}
end

require("conform").setup({
  notify_on_error = false,
  formatters_by_ft = {
    ["_"] = { "trim_whitespace", "trim_newlines" },
    astro = { "oxfmt", lsp_format = "prefer" },
    bash = { "shfmt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    cs = { "csharpier_zjom" },
    csproj = { "csharpier_zjom" },
    css = { "oxfmt" },
    elixir = { "mix", lsp_format = "prefer" },
    fish = { "fish_indent" },
    go = { "gofumpt", lsp_format = "fallback" },
    html = { "oxfmt" },
    http = { "kulala-fmt" },
    java = { "palantir-java-format" },
    javascript = { "oxfmt" },
    javascriptreact = { "oxfmt" },
    just = { "just" },
    json = { "oxfmt" },
    jsonc = { "oxfmt" },
    less = { "oxfmt" },
    lua = { "stylua", lsp_format = "prefer" },
    markdown = { "oxfmt" },
    nix = { "nixfmt" },
    nu = { "nufmt" },
    ocaml = { "ocamlformat", lsp_format = "prefer" },
    opentofu = { "tofu_fmt", lsp_format = "fallback" },
    opentofu_vars = { "tofu_fmt", lsp_format = "fallback" },
    terraform = { "tofu_fmt", lsp_format = "fallback" },
    python = {
      "ruff_fix",
      "ruff_format",
      "ruff_organize_imports",
    },
    rust = { "rustfmt", lsp_format = "prefer" },
    scss = { "oxfmt" },
    sh = { "shfmt" },
    sql = { "sleek" },
    svelte = { "prettier" },
    toml = { "oxfmt" },
    typescript = { "oxfmt" },
    typescriptreact = { "oxfmt" },
    typst = { "typstyle" },
    yaml = { "oxfmt" },
    zig = { "zigfmt" },
    zsh = { "shfmt" },
  },
  formatters = {
    csharpier_zjom = {
      command = "csharpier",
      args = {
        "format",
        "--write-stdout",
      },
      to_stdin = true,
    },
  },
  format_on_save = format_on_save,
  default_format_opts = {
    lsp_format = "fallback", -- An external formatter below has priority over LSP formatting. To disable LSP formatting fully, set this value to `false`.
  },
})

vim.keymap.set({ "n", "v" }, "<leader>bf", function()
  require("conform").format({ async = true })
end, { desc = "[B]uffer [F]ormat" })
