--[[
═══════════════════════════════════════════════════════════════════════════════
                           EDITOR OPTIONS CONFIGURATION
                           
Optimized Neovim editor settings for Python development.
Focus on performance, usability, and Python-specific configurations.

Categories:
- Performance optimizations
- Editor behavior and UI
- Search and navigation
- File handling and backup
═══════════════════════════════════════════════════════════════════════════════
--]]

local M = {}

---Setup performance optimizations and startup improvements
function M.setup_performance()
  -- Enable new Lua loader for faster startup
  vim.loader.enable()
  
  -- Disable unnecessary default plugins
  local disabled_plugins = {
    'gzip', 'zip', 'tar', '2html_plugin', 'matchit'
  }
  
  for _, plugin in ipairs(disabled_plugins) do
    vim.g['loaded_' .. plugin] = 1
  end
end

---Setup leader keys and basic configuration
function M.setup_leaders()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = false  -- Ensure compatibility without nerd fonts
end

---Setup editor behavior and UI
function M.setup_editor()
  local opt = vim.opt
  
  -- UI and display
  opt.number = true                 -- Show line numbers
  opt.cursorline = true            -- Highlight current line
  opt.signcolumn = 'yes'           -- Always show sign column
  opt.scrolloff = 10               -- Keep 10 lines above/below cursor
  opt.showmode = false             -- Don't show mode in command line
  opt.termguicolors = true         -- Enable 24-bit RGB colors
  
  -- Mouse and interaction
  opt.mouse = 'a'                  -- Enable mouse in all modes
  opt.confirm = true               -- Confirm before closing unsaved files
  
  -- Performance and responsiveness
  opt.updatetime = 500             -- Debounce diagnostics for smoother editing
  opt.timeoutlen = 300            -- Faster keymap timeout
  
  -- File handling
  opt.undofile = true             -- Persistent undo history
  
  -- Window splitting
  opt.splitright = true           -- Vertical splits go right
  opt.splitbelow = true           -- Horizontal splits go below
end

---Setup search behavior
function M.setup_search()
  local opt = vim.opt
  
  opt.ignorecase = true           -- Case insensitive search
  opt.smartcase = true            -- Case sensitive if uppercase used
  opt.inccommand = 'split'        -- Live preview of substitutions
end

---Setup clipboard integration (async for performance)
function M.setup_clipboard()
  vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
  end)
end

---Setup all editor options
function M.setup()
  M.setup_performance()
  M.setup_leaders()
  M.setup_editor()
  M.setup_search()
  M.setup_clipboard()
end

---Get current configuration summary for debugging
---@return table config Current configuration state
function M.get_config_summary()
  return {
    leader = vim.g.mapleader,
    has_nerd_font = vim.g.have_nerd_font,
    termguicolors = vim.opt.termguicolors:get(),
    updatetime = vim.opt.updatetime:get(),
    timeoutlen = vim.opt.timeoutlen:get(),
    clipboard = vim.opt.clipboard:get(),
  }
end

return M