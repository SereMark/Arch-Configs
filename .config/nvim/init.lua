-- Modern Neovim config
vim.g.mapleader = ' '

-- Essential options
for opt, val in pairs({
  number = true, expandtab = true, shiftwidth = 2, undofile = true,
  clipboard = 'unnamedplus', termguicolors = true, mouse = 'a',
  ignorecase = true, smartcase = true, updatetime = 250, scrolloff = 4
}) do vim.opt[opt] = val end

-- Auto-install plugins
vim.iter({'ibhagwan/fzf-lua', 'catppuccin/nvim', 'nvim-treesitter/nvim-treesitter'}):each(function(repo)
  local path = vim.fs.joinpath(vim.fn.stdpath('data'), 'site/pack/plugins/start', repo:match('([^/]+)$'))
  if not vim.uv.fs_stat(path) then vim.fn.system({'git', 'clone', '--depth=1', 'https://github.com/' .. repo, path}) end
end)

-- Protected plugin setup
local function setup_plugin(name, config_fn)
  local ok, plugin = pcall(require, name)
  if ok then config_fn(plugin) end
end

vim.defer_fn(function()
  -- FZF keymaps
  setup_plugin('fzf-lua', function(fzf)
    fzf.setup({ files = { fd_opts = "--color=never --type f --hidden --follow --exclude build --exclude .git --exclude __pycache__ --exclude venv" } })
    for k, v in pairs({sf = 'files', sg = 'live_grep', sb = 'buffers'}) do vim.keymap.set('n', '<leader>' .. k, fzf[v]) end
  end)

  -- Theme
  setup_plugin('catppuccin', function(catppuccin)
    catppuccin.setup({ flavour = 'mocha', integrations = { treesitter = true, native_lsp = { enabled = true } } })
    vim.cmd.colorscheme('catppuccin')
  end)

  -- Treesitter
  setup_plugin('nvim-treesitter.configs', function(ts)
    ts.setup({
      ensure_installed = { "python", "cpp", "c", "lua", "vim", "vimdoc", "query" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true }
    })
  end)
end, 100)

-- LSP configuration
local lsps = {
  pyright = { cmd = 'pyright-langserver', filetypes = { 'python' }, roots = { 'pyproject.toml', 'setup.py', '.git' } },
  clangd = { cmd = 'clangd', filetypes = { 'c', 'cpp' }, roots = { 'compile_commands.json', 'CMakeLists.txt', '.git' } }
}

for name, config in pairs(lsps) do
  if vim.fn.executable(config.cmd) == 1 then
    vim.lsp.config(name, {
      cmd = { config.cmd, name == 'pyright' and '--stdio' or '--background-index' },
      root_markers = config.roots,
      filetypes = config.filetypes
    })
  end
end

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    local map = function(keys, func) vim.keymap.set('n', keys, func, { buffer = args.buf }) end
    map('K', vim.lsp.buf.hover)
    map('gd', vim.lsp.buf.definition)
  end
})

vim.lsp.enable(vim.tbl_keys(lsps))
