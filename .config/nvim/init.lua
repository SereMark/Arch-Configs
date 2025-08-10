-- Minimal, viewer-focused Neovim
vim.g.mapleader = ' '

-- Keep essentials for reading/code navigation; lean on defaults otherwise
for opt, val in pairs({
  number = true, termguicolors = true, mouse = 'a', clipboard = 'unnamedplus',
  ignorecase = true, smartcase = true, updatetime = 250, scrolloff = 4,
  signcolumn = 'yes',
}) do vim.opt[opt] = val end

-- Bootstrap required plugins (fzf-lua, catppuccin, treesitter, gitsigns, diffview)
for _, repo in ipairs({
  'ibhagwan/fzf-lua', 'catppuccin/nvim', 'nvim-treesitter/nvim-treesitter',
  'nvim-lua/plenary.nvim', 'lewis6991/gitsigns.nvim', 'sindrets/diffview.nvim',
}) do
  local dir = vim.fn.stdpath('data') .. '/site/pack/plugins/start/' .. repo:match('([^/]+)$')
  if not vim.uv.fs_stat(dir) then vim.fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/' .. repo, dir }) end
end

-- FZF (defaults) + concise keymaps
do local ok, fzf = pcall(require, 'fzf-lua'); if ok then
  -- Determine a sensible project root for pickers
  local function project_root()
    local current_buffer = vim.api.nvim_get_current_buf()
    local buffer_name = vim.api.nvim_buf_get_name(current_buffer)
    local start_dir = (buffer_name ~= '' and vim.fs.dirname(buffer_name)) or vim.uv.cwd()
    local markers = {
      '.git', '.hg', '.svn',
      'package.json', 'pnpm-workspace.yaml', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb',
      'pyproject.toml', 'poetry.lock', 'requirements.txt',
      'Cargo.toml', 'go.mod', 'composer.json', 'mix.exs',
      'Makefile', 'CMakeLists.txt', '.root'
    }
    local found = vim.fs.find(markers, { path = start_dir, upward = true })[1]
    return found and vim.fs.dirname(found) or start_dir
  end

  fzf.setup({
    -- Keep a lean UI (no icons)
    files = { file_icons = false, git_icons = false, color_icons = false },
    grep = { file_icons = false, git_icons = false, color_icons = false },
    buffers = { file_icons = false, color_icons = false },
    oldfiles = { file_icons = false, git_icons = false, color_icons = false },
  })
  -- Keymaps: scope project-aware pickers to the detected root
  vim.keymap.set('n', '<leader>sf', function() fzf.files({ cwd = project_root() }) end)
  vim.keymap.set('n', '<leader>sg', function() fzf.live_grep({ cwd = project_root() }) end)
  vim.keymap.set('n', '<leader>sb', fzf.buffers)
  vim.keymap.set('n', '<leader>gf', function() fzf.git_files({ cwd = project_root() }) end)
end end

-- Theme
pcall(vim.cmd.colorscheme, 'catppuccin')


-- Treesitter: highlight only
do local ok, ts = pcall(require, 'nvim-treesitter.configs'); if ok then
  ts.setup({
    highlight = { enable = true },
    ensure_installed = { 'python', 'c', 'cpp', 'lua', 'vim', 'query' },
    auto_install = false,
  })
end end

-- Git signs (read-only friendly bindings)
do local ok, gs = pcall(require, 'gitsigns'); if ok then
  gs.setup({
    on_attach = function(bufnr)
      local map = function(lhs, fn) vim.keymap.set('n', lhs, fn, { buffer = bufnr }) end
      map(']h', gs.next_hunk); map('[h', gs.prev_hunk); map('<leader>hp', gs.preview_hunk)
    end
  })
end end

-- Diffview: side-by-side diffs for PR-style review
pcall(function() require('diffview').setup({ use_icons = false }) end)

vim.keymap.set('n', '<leader>dv', function() vim.cmd('DiffviewOpen') end, { desc = 'Diffview Open' })
vim.keymap.set('n', '<leader>dx', function() vim.cmd('DiffviewClose') end, { desc = 'Diffview Close' })
