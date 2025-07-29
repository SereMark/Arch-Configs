vim.g.mapleader = ' '
vim.loader.enable()

vim.opt.number, vim.opt.cursorline, vim.opt.signcolumn = true, true, 'yes'
vim.opt.undofile, vim.opt.ignorecase, vim.opt.smartcase = true, true, true
vim.opt.termguicolors, vim.opt.scrolloff, vim.opt.sidescrolloff = true, 4, 4
vim.opt.laststatus, vim.opt.clipboard = 0, 'unnamedplus'

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }):wait()
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'ibhagwan/fzf-lua',
    keys = {
      { '<leader>sf', function() require('fzf-lua').files() end, desc = 'Find files' },
      { '<leader>sg', function() require('fzf-lua').live_grep() end, desc = 'Live grep' },
      { '<leader>sb', function() require('fzf-lua').buffers() end, desc = 'Find buffers' },
      { '<leader>sh', function() require('fzf-lua').help_tags() end, desc = 'Help tags' },
    },
  },
  { 'rose-pine/neovim', lazy = false, priority = 1000, config = function() vim.cmd.colorscheme('rose-pine') end },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
  end,
})

vim.lsp.config('ruff', {
  cmd = { '/home/seremark/.local/ruff-venv/bin/ruff', 'server' },
  on_attach = function(c) c.server_capabilities.hoverProvider = false end,
})

vim.lsp.config('basedpyright', {
  cmd = { '/home/seremark/.local/basedpyright-venv/bin/basedpyright-langserver', '--stdio' },
  before_init = function(_, c) 
    c.settings = c.settings or {}
    c.settings.python = { pythonPath = vim.fs.joinpath(vim.uv.cwd(), 'venv', 'bin', 'python') } 
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.py',
  callback = function() vim.lsp.buf.format() end,
})

vim.lsp.enable({ 'ruff', 'basedpyright' })