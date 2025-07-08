-- ~/.config/nvim/init.lua
--
-- Main configuration file for Neovim.
-- Sets global options, core keymaps, and bootstraps the plugin manager.

-- -----------------------------------------------------------------------------
-- SECTION 1: LAZY.NVIM BOOTSTRAP
-- -----------------------------------------------------------------------------
-- This section ensures that the lazy.nvim plugin manager is installed and loaded.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- -----------------------------------------------------------------------------
-- SECTION 2: GLOBAL OPTIONS
-- -----------------------------------------------------------------------------
-- For a complete list of options, run `:help option-list`

-- Leader Keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- UI & Appearance
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative line numbers
vim.opt.termguicolors = true      -- Enable 24-bit RGB colors
vim.opt.signcolumn = 'yes'        -- Always show the sign column to avoid visual shifts
vim.opt.scrolloff = 8             -- Keep 8 lines of context around the cursor
vim.opt.showmode = false          -- Hide the default mode text (lualine will handle this)
vim.opt.updatetime = 250          -- Time in ms to wait for trigger events (e.g., CursorHold)
vim.opt.timeoutlen = 300          -- Time in ms to wait for a mapped sequence to complete

-- Search Behavior
vim.opt.hlsearch = true           -- Highlight all matches on search
vim.opt.incsearch = true          -- Show search results incrementally
vim.opt.ignorecase = true         -- Ignore case in search patterns
vim.opt.smartcase = true          -- Override ignorecase if search pattern contains uppercase letters

-- Tabs & Indentation
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.shiftwidth = 2            -- Number of spaces for indentation
vim.opt.tabstop = 2               -- Number of spaces a <Tab> counts for

-- System Integration
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard for copy/paste
vim.opt.mouse = 'a'               -- Enable mouse support in all modes

-- -----------------------------------------------------------------------------
-- SECTION 3: CORE KEYMAPS
-- -----------------------------------------------------------------------------
-- These are essential keymaps that do not depend on any plugins.
local keymap = vim.keymap.set

-- General
keymap('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save File' })
keymap('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })

-- Clear search highlighting
keymap('n', '<leader>c', '<cmd>nohlsearch<CR>', { desc = 'Clear Search Highlight' })

-- Buffer Navigation
keymap('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next Buffer' })
keymap('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Previous Buffer' })
keymap('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete Buffer' })

-- -----------------------------------------------------------------------------
-- SECTION 4: PLUGIN MANAGER SETUP
-- -----------------------------------------------------------------------------
-- Load the plugins defined in `lua/plugins.lua`.
require('lazy').setup('plugins')
