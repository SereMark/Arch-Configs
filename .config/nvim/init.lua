--[[
═══════════════════════════════════════════════════════════════════════════════
                        PERFECT MINIMAL PYTHON CONFIG
                        
Ultra-clean Neovim configuration optimized for Python development.
Zero redundancy, maximum performance, semantic highlighting perfection.

Version: 6.0.0 - Modular Architecture  
Architecture: Ruff LSP + Basedpyright + Essential Tools Only
Neovim: 0.9.0+
═══════════════════════════════════════════════════════════════════════════════
--]]

-- Setup core editor options and performance optimizations
require('options').setup()

-- Setup global keymaps
require('keymaps').setup()

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Python-specific configuration
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  group = vim.api.nvim_create_augroup('python-config', { clear = true }),
  callback = function(args)
    require('python-env').setup_python_buffer(args.buf)
  end,
})

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local success, result = pcall(vim.fn.system, {
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if not success or vim.v.shell_error ~= 0 then
    vim.notify('Failed to clone lazy.nvim: ' .. (result or 'Unknown error'), vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require('lazy').setup({
  -- Auto-pairs
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' }, change = { text = '~' }, delete = { text = '_' },
        topdelete = { text = '‾' }, changedelete = { text = '~' },
      },
    },
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable('make') == 1 end },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = { file_ignore_patterns = { '%.git/', '__pycache__/', '%.pyc' } },
      })
      pcall(telescope.load_extension, 'fzf')
      require('keymaps').setup_telescope_keymaps()
    end,
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      require('lsp-config').setup()
    end,
  },

  -- Completion
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    build = 'cargo build --release',
    dependencies = { 
      {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp',
        config = function()
          local luasnip = require('luasnip')
          local s, t, i = luasnip.snippet, luasnip.text_node, luasnip.insert_node
          luasnip.add_snippets('python', {
            s('def', { t('def '), i(1, 'function'), t('('), i(2), t('):'), t({'', '    '}), i(3, 'pass') }),
            s('class', { t('class '), i(1, 'Class'), t('('), i(2), t('):'), t({'', '    '}), i(3, 'pass') }),
            s('if', { t('if '), i(1, 'condition'), t(':'), t({'', '    '}), i(2, 'pass') }),
            s('for', { t('for '), i(1, 'item'), t(' in '), i(2, 'items'), t(':'), t({'', '    '}), i(3, 'pass') }),
            s('main', { t('if __name__ == "__main__":'), t({'', '    '}), i(1, 'main()') }),
          })
        end,
      }
    },
    opts = {
      keymap = { preset = 'default' },
      sources = { default = { 'lsp', 'path', 'snippets' } },
      snippets = { preset = 'luasnip' },
      completion = { menu = { border = 'rounded' } },
      fuzzy = { implementation = 'lua' },
    },
  },

  -- Professional colorscheme
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      local colors_module = require('colors')
      require('tokyonight').setup({
        style = 'night',
        terminal_colors = true,
        styles = { comments = { italic = true }, keywords = { italic = true }, functions = { bold = true } },
        on_colors = colors_module.setup_colors,
        on_highlights = colors_module.setup_syntax_highlighting,
      })
      vim.cmd.colorscheme('tokyonight')
    end,
  },

  -- Statusline and utilities
  {
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('mini.statusline').setup({ use_icons = false })
      require('mini.indentscope').setup({
        draw = { delay = 100, animation = require('mini.indentscope').gen_animation.none() },
        mappings = { object_scope = 'ii', object_scope_with_border = 'ai', goto_top = '[i', goto_bottom = ']i' },
        options = { try_as_border = true },
        symbol = '│',
      })
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'python', 'lua', 'vim', 'vimdoc' },
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = true,
        textobjects = {
          select = {
            enable = true, lookahead = true,
            keymaps = { ['af'] = '@function.outer', ['if'] = '@function.inner', ['ac'] = '@class.outer', ['ic'] = '@class.inner' },
          },
          move = {
            enable = true, set_jumps = true,
            goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer' },
            goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer' },
            goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer' },
            goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer' },
          },
        },
      })
    end,
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙', keys = '🗝',
      plugin = '🔌', runtime = '💻', require = '🌙', source = '📄', start = '🚀', task = '📌', lazy = '💤 ',
    },
    border = 'rounded',
  },
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- vim: ts=2 sts=2 sw=2 et