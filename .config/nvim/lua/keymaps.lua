--[[
═══════════════════════════════════════════════════════════════════════════════
                             KEYMAP CONFIGURATION
                             
Centralized keymap configuration for consistent and organized keybindings.
Includes global keymaps and Python-specific keybindings.

Categories:
- Core navigation and editing
- Search and file operations  
- Python development workflow
- Diagnostic and LSP operations
═══════════════════════════════════════════════════════════════════════════════
--]]

local M = {}

---Setup core global keymaps
function M.setup_global_keymaps()
  -- Clear search highlighting
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlighting' })
  
  -- Diagnostics
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix' })
  
  -- Window navigation
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })
  
  -- Python commenting toggle
  vim.keymap.set('n', '<leader>/', function()
    local line = vim.api.nvim_get_current_line()
    local new_line = line:match('^%s*#') 
      and line:gsub('^(%s*)# ?', '%1')
      or line:gsub('^(%s*)', '%1# ')
    vim.api.nvim_set_current_line(new_line)
  end, { desc = 'Toggle Python comment' })
end

---Setup telescope search keymaps
function M.setup_telescope_keymaps()
  local builtin = require('telescope.builtin')
  
  local telescope_maps = {
    { '<leader>sf', builtin.find_files, 'Search files' },
    { '<leader>sg', builtin.live_grep, 'Search by grep' },
    { '<leader>sb', builtin.buffers, 'Search buffers' },
    { '<leader>sh', builtin.help_tags, 'Search help' },
    { '<leader>sd', builtin.diagnostics, 'Search diagnostics' },
  }
  
  for _, map in ipairs(telescope_maps) do
    vim.keymap.set('n', map[1], map[2], { desc = map[3] })
  end
end

---Initialize all keymaps
function M.setup()
  M.setup_global_keymaps()
  
  -- Setup telescope keymaps when telescope is available
  local telescope_ok, _ = pcall(require, 'telescope.builtin')
  if telescope_ok then
    M.setup_telescope_keymaps()
  end
end

return M