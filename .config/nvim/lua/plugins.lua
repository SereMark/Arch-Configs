-- ~/.config/nvim/lua/plugins.lua
--
-- All plugin specifications are defined here.
-- For more details, see the lazy.nvim documentation.

return {

  -- -----------------------------------------------------------------------------
  -- SECTION 1: CORE UI & UTILITIES
  -- -----------------------------------------------------------------------------

  -- Colorscheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000, -- Ensures the colorscheme is loaded first
    config = function()
      vim.cmd.colorscheme('catppuccin')
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Optional: for file icons
    config = function()
      require('lualine').setup({
        options = {
          theme = 'catppuccin',
          component_separators = '',
          section_separators = '',
        },
      })
    end,
  },

  -- File Explorer
  {
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    keys = { { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle File Explorer' } },
    config = function()
      require('nvim-tree').setup({
        disable_netrw = true, -- Crucial for nvim-tree to work correctly
        hijack_netrw = true,  -- Replaces netrw when opening directories
        view = {
          width = 30,
          side = 'left',
        },
        renderer = {
          group_empty = true,
          icons = {
            show = { git = false },
          },
        },
      })
    end,
  },

  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find Files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Grep Text' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Find Buffers' },
    },
  },

  -- -----------------------------------------------------------------------------
  -- SECTION 2: CODING ESSENTIALS
  -- -----------------------------------------------------------------------------

  -- Syntax Highlighting Engine
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' }, -- Load treesitter early for highlighting
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Ensure parsers for common languages are installed
        ensure_installed = { 'c', 'lua', 'python', 'vim', 'vimdoc', 'javascript', 'html' },
        auto_install = true, -- Automatically install parsers for new languages
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- Git Integration
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitsigns').setup()
    end,
  },

  -- -----------------------------------------------------------------------------
  -- SECTION 3: LSP (Language Server Protocol) & COMPLETION
  -- -----------------------------------------------------------------------------

  -- LSP Installer & Manager
  {
    'williamboman/mason.nvim',
    event = 'VeryLazy',
    config = function()
      require('mason').setup()
    end,
  },

  -- Bridge between Mason and LSPConfig
  {
    'williamboman/mason-lspconfig.nvim',
    event = 'VeryLazy',
    dependencies = { 'williamboman/mason.nvim' },
  },

  -- Core LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      -- This on_attach function will be passed to LSPs, setting keymaps on attach
      local on_attach = function(client, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: ' .. desc })
        end

        map('gd', vim.lsp.buf.definition, 'Go to Definition')
        map('gr', vim.lsp.buf.references, 'Go to References')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>lr', vim.lsp.buf.rename, 'Rename')
        map('<leader>la', vim.lsp.buf.code_action, 'Code Action')
        map('<leader>ld', vim.diagnostic.open_float, 'Show Line Diagnostics')
      end

      -- The correct, single setup call for mason-lspconfig
      require('mason-lspconfig').setup({
        -- A list of servers to install if they're not already installed
        ensure_installed = { 'lua_ls', 'pyright' },

        -- This is the handler that will be called for each server
        handlers = {
          -- Default handler: sets up LSP with our on_attach function
          function(server_name)
            require('lspconfig')[server_name].setup({
              on_attach = on_attach,
            })
          end,
        },
      })
    end,
  },

  -- Autocompletion Engine
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'L3MON4D3/LuaSnip', -- Snippet engine
      'saadparwaiz1/cmp_luasnip', -- Snippet source for nvim-cmp
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
        }),
        -- Order of sources matters!
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
        }),
      })
    end,
  },
}
