vim.g.mapleader = ' '
vim.opt.number, vim.opt.cursorline, vim.opt.signcolumn = true, true, 'yes'
vim.opt.undofile, vim.opt.ignorecase, vim.opt.smartcase = true, true, true
vim.opt.termguicolors, vim.opt.splitbelow, vim.opt.splitright = true, true, true
vim.opt.scrolloff, vim.opt.sidescrolloff, vim.opt.updatetime = 8, 8, 250
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath })
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
  {
    'ibhagwan/fzf-lua',
    keys = { '<leader>sf', '<leader>sg', '<leader>sb', '<leader>sh' },
    config = function()
      require('fzf-lua').setup({
        winopts = {
          height = 0.85,
          width = 0.80,
          row = 0.35,
          col = 0.50,
          border = 'rounded',
        },
        keymap = {
          fzf = {
            ['ctrl-q'] = 'select-all+accept',
          },
        },
        files = {
          rg_opts = "--color=never --files --hidden --follow -g '!.git'",
        },
        grep = {
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096",
        },
      })
      
      local fzf = require('fzf-lua')
      vim.keymap.set('n', '<leader>sf', fzf.files)
      vim.keymap.set('n', '<leader>sg', fzf.live_grep)
      vim.keymap.set('n', '<leader>sb', fzf.buffers)
      vim.keymap.set('n', '<leader>sh', fzf.help_tags)
    end,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    config = function()
      require('rose-pine').setup({
        variant = 'auto',
        dark_variant = 'moon',
        styles = {
          bold = false,
          italic = false,
          transparency = false,
        },
      })
      vim.cmd.colorscheme('rose-pine')
    end
  },
  {
    'echasnovski/mini.nvim',
    event = 'UIEnter',
    config = function()
      require('mini.statusline').setup({
        use_icons = false,
        set_vim_settings = false,
      })
      
      require('mini.indentscope').setup({
        symbol = '│',
        options = { try_as_border = true },
        draw = {
          delay = 100,
          animation = require('mini.indentscope').gen_animation.none(),
        },
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 
          'python', 'lua', 'vim', 'vimdoc', 'query',
          'bash', 'json', 'yaml', 'toml', 'markdown',
          'typescript', 'javascript'
        },
        sync_install = false,
        auto_install = true,
        highlight = { 
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
      })
      
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.opt.foldenable = false
    end
  },
})

vim.lsp.config('*', {
  on_attach = function(_, bufnr)
    local map = function(k, f, desc) 
      vim.keymap.set('n', k, f, { buffer = bufnr, desc = desc }) 
    end
    local fzf = require('fzf-lua')
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gr', vim.lsp.buf.references, 'Go to references')  
    map('gi', vim.lsp.buf.implementation, 'Go to implementation')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    map('K', vim.lsp.buf.hover, 'Hover documentation')
    map('<C-k>', vim.lsp.buf.signature_help, 'Signature help')
  end,
})

vim.lsp.config('ruff', {
  cmd = { '/home/seremark/.local/ruff-venv/bin/ruff', 'server' },
  filetypes = { 'python' },
  on_attach = function(c) c.server_capabilities.hoverProvider = false end
})
vim.lsp.config('basedpyright', {
  cmd = { '/home/seremark/.local/basedpyright-venv/bin/basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  settings = { basedpyright = { analysis = { typeCheckingMode = 'basic', autoSearchPaths = true } } },
  before_init = function(_, c) c.settings.python = { pythonPath = vim.fn.getcwd() .. '/venv/bin/python' } end
})
vim.lsp.enable({ 'ruff', 'basedpyright' })
