-- Leader key
vim.g.mapleader = ' '

-- Essential options
vim.opt.number, vim.opt.cursorline, vim.opt.signcolumn = true, true, 'yes'
vim.opt.undofile, vim.opt.ignorecase, vim.opt.smartcase = true, true, true
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require('lazy').setup({
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = { '<leader>sf', '<leader>sg', '<leader>sb', '<leader>sh' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable('make') == 1 end },
    },
    config = function()
      require('telescope').setup()
      pcall(require('telescope').load_extension, 'fzf')
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sf', builtin.find_files)
      vim.keymap.set('n', '<leader>sg', builtin.live_grep)
      vim.keymap.set('n', '<leader>sb', builtin.buffers)
      vim.keymap.set('n', '<leader>sh', builtin.help_tags)
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = { flavour = 'mocha' },
    config = function() vim.cmd.colorscheme('catppuccin') end,
  },
  
  {
    'echasnovski/mini.nvim',
    event = 'UIEnter',
    config = function()
      require('mini.statusline').setup({ use_icons = false })
      require('mini.indentscope').setup()
    end,
  },
  
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'python', 'lua', 'vim' },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
})

-- Modern LSP configuration (Neovim 0.11+)
vim.lsp.config('*', {
  on_attach = function(client, bufnr)
    local map = function(keys, func) vim.keymap.set('n', keys, func, { buffer = bufnr }) end
    local builtin = require('telescope.builtin')
    map('grd', builtin.lsp_definitions)
    map('grr', builtin.lsp_references)
    map('gra', vim.lsp.buf.code_action)
    map('grn', vim.lsp.buf.rename)
    map('K', vim.lsp.buf.hover)
  end,
})

vim.lsp.config('ruff', { 
  cmd = { '/home/seremark/.local/ruff-venv/bin/ruff', 'server' },
  filetypes = { 'python' },
  on_attach = function(client) client.server_capabilities.hoverProvider = false end 
})
vim.lsp.config('basedpyright', { 
  cmd = { '/home/seremark/.local/basedpyright-venv/bin/basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  settings = { basedpyright = { analysis = { typeCheckingMode = 'basic', autoSearchPaths = true } } },
  before_init = function(_, config)
    local function find_python_path()
      if vim.env.VIRTUAL_ENV then
        return vim.env.VIRTUAL_ENV .. '/bin/python'
      end
      
      local cwd = vim.fn.getcwd()
      local candidates = {
        cwd .. '/venv/bin/python',
        cwd .. '/.venv/bin/python',
        vim.fn.expand('~/') .. 'projects/' .. vim.fn.fnamemodify(cwd, ':t') .. '/venv/bin/python'
      }
      
      for _, path in ipairs(candidates) do
        if vim.fn.executable(path) == 1 then
          return path
        end
      end
      
      return 'python3'
    end
    
    config.settings.python = { pythonPath = find_python_path() }
  end,
})
vim.lsp.enable({ 'ruff', 'basedpyright' })
