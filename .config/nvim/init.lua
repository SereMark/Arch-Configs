--[[
═══════════════════════════════════════════════════════════════════════════════
                        PERFECT MINIMAL PYTHON CONFIG
                        
Ultra-clean Neovim configuration optimized for Python development.
Zero redundancy, maximum performance, semantic highlighting perfection.

Version: 5.0.0 - Ultra-Minimal & Professional
Architecture: Ruff LSP + Basedpyright + Essential Tools Only
Neovim: 0.9.0+
═══════════════════════════════════════════════════════════════════════════════
--]]

-- Performance optimization and startup improvements
vim.loader.enable()

-- Disable unnecessary default plugins
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_tar = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1

-- ═══════════════════════════════════════════════════════════════════════════
-- CORE CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════

-- Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

-- Editor settings
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.scrolloff = 10
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.undofile = true
vim.opt.confirm = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'split'
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Async clipboard setup
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- KEYMAPS
-- ═══════════════════════════════════════════════════════════════════════════

-- Clear search highlighting
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostics
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Python commenting
vim.keymap.set('n', '<leader>/', function()
  local line = vim.api.nvim_get_current_line()
  local new_line = line:match('^%s*#') 
    and line:gsub('^(%s*)# ?', '%1')
    or line:gsub('^(%s*)', '%1# ')
  vim.api.nvim_set_current_line(new_line)
end, { desc = 'Toggle Python comment' })


-- ═══════════════════════════════════════════════════════════════════════════
-- AUTOCOMMANDS
-- ═══════════════════════════════════════════════════════════════════════════

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PYTHON ENVIRONMENT DETECTION
-- ═══════════════════════════════════════════════════════════════════════════

-- Simple memoization cache
local python_path_cache = {}

local function find_project_root(start_path)
  local root_markers = { '.git', 'pyproject.toml', 'requirements.txt', 'setup.py', 'Pipfile' }
  local current = start_path or vim.fn.getcwd()
  
  while current ~= '/' do
    for _, marker in ipairs(root_markers) do
      local marker_path = current .. '/' .. marker
      if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
        return current
      end
    end
    current = vim.fn.fnamemodify(current, ':h')
  end
  return nil
end

local function extract_venv_name(python_path)
  if not python_path or python_path == '' then return 'sys' end
  return python_path:match('/([^/]+)/bin/python$') or 'sys'
end

function get_python_path(buffer_path)
  local start_dir = buffer_path and vim.fn.fnamemodify(buffer_path, ':h') or vim.fn.getcwd()
  
  -- Check cache first
  if python_path_cache[start_dir] then
    return python_path_cache[start_dir]
  end
  
  local python_path
  
  -- 1. Use activated virtualenv (highest priority)
  if vim.env.VIRTUAL_ENV then
    local venv_python = vim.env.VIRTUAL_ENV .. '/bin/python'
    if vim.fn.filereadable(venv_python) == 1 then
      python_path = venv_python
    end
  end
  
  -- 2. Find project root and check for local venv
  if not python_path then
    local project_root = find_project_root(start_dir)
    if project_root then
      local venv_names = { 'venv', '.venv', 'env', '.env' }
      for _, venv_name in ipairs(venv_names) do
        local venv_python = project_root .. '/' .. venv_name .. '/bin/python'
        if vim.fn.filereadable(venv_python) == 1 then
          python_path = venv_python
          break
        end
      end
    end
  end
  
  -- 3. Check for pyenv
  if not python_path then
    local result = vim.fn.system('pyenv which python 2>/dev/null')
    if vim.v.shell_error == 0 and result then
      python_path = result:gsub('%s+', '')
    end
  end
  
  -- 4. Check for conda
  if not python_path and vim.env.CONDA_PREFIX then
    local conda_python = vim.env.CONDA_PREFIX .. '/bin/python'
    if vim.fn.filereadable(conda_python) == 1 then
      python_path = conda_python
    end
  end
  
  -- 5. Default to system Python
  if not python_path then
    python_path = vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python3'
  end
  
  -- Cache the result
  python_path_cache[start_dir] = python_path
  return python_path
end

-- Dynamic Python environment detection and LSP reconfiguration
local current_python_path = nil

function update_python_lsp(buffer_path)
  local new_python_path = get_python_path(buffer_path)
  
  if current_python_path ~= new_python_path then
    current_python_path = new_python_path
    
    -- Update basedpyright LSP client
    for _, client in pairs(vim.lsp.get_clients()) do
      if client.name == 'basedpyright' and client.config and client.config.settings then
        client.config.settings.python = client.config.settings.python or {}
        client.config.settings.python.pythonPath = new_python_path
        
        -- Notify the LSP server of the configuration change
        pcall(client.notify, 'workspace/didChangeConfiguration', {
          settings = client.config.settings
        })
      end
    end
    
    -- Show notification of venv change
    local venv_name = extract_venv_name(new_python_path)
    if venv_name == 'sys' then venv_name = 'system' end
    vim.notify('Python: ' .. venv_name, vim.log.levels.INFO)
  end
end

-- Python-specific configuration with dynamic venv detection
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  group = vim.api.nvim_create_augroup('python-config', { clear = true }),
  callback = function(args)
    local buf = args.buf
    
    -- Python settings (consolidated)
    vim.bo[buf].textwidth, vim.bo[buf].expandtab = 88, true
    vim.bo[buf].shiftwidth, vim.bo[buf].softtabstop, vim.bo[buf].tabstop = 4, 4, 4
    vim.wo.foldmethod, vim.wo.foldlevel = 'indent', 99
    
    -- Update Python LSP for this project (optimized with early exit)
    local buffer_path = vim.api.nvim_buf_get_name(buf)
    if buffer_path ~= '' then
      -- Update Python LSP if environment changed
      local new_python_path = get_python_path(buffer_path)
      if current_python_path ~= new_python_path then
        update_python_lsp(buffer_path)
      end
    end
    
    -- Python keymaps (streamlined)
    local map = function(key, func, desc)
      vim.keymap.set('n', key, func, { buffer = buf, silent = true, desc = desc })
    end
    
    -- Test runner (optimized to use detected Python)
    map('<leader>t', function()
      local file = vim.api.nvim_buf_get_name(buf)
      if file == '' then return end
      
      local python_path = get_python_path(file)
      local cmd = file:match('test.*%.py$') 
        and { python_path, '-m', 'pytest', file } 
        or { python_path, file }
      
      vim.system(cmd, { text = true }, function(result)
        local message = result.code == 0 and 'Execution completed' 
          or 'Execution failed: ' .. (result.stderr or result.stdout or 'Unknown')
        local level = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        vim.notify(message, level)
      end)
    end, 'Run Python file/test')
    
    -- REPL integration (optimized to use detected Python)
    map('<leader>r', function()
      local line = vim.api.nvim_get_current_line()
      if line:match('%S') then
        local file = vim.api.nvim_buf_get_name(buf)
        local python_path = get_python_path(file)
        
        vim.system({ python_path, '-c', line }, { text = true }, function(result)
          if result.stdout and result.stdout:match('%S') then 
            vim.notify('Output: ' .. result.stdout, vim.log.levels.INFO) 
          elseif result.stderr and result.stderr:match('%S') then
            vim.notify('Error: ' .. result.stderr, vim.log.levels.ERROR)
          end
        end)
      end
    end, 'Execute line in Python')
    
    -- Docstring generation (compact)
    map('<leader>d', function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      if vim.api.nvim_get_current_line():match('def ') then
        vim.api.nvim_buf_set_lines(buf, row, row, false, {'    """', '    """'})
        vim.api.nvim_win_set_cursor(0, {row + 1, 7})
        vim.cmd('startinsert')
      end
    end, 'Generate docstring')
  end,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PLUGIN MANAGER
-- ═══════════════════════════════════════════════════════════════════════════

-- Bootstrap lazy.nvim with comprehensive error handling
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

-- ═══════════════════════════════════════════════════════════════════════════
-- PLUGINS
-- ═══════════════════════════════════════════════════════════════════════════

-- Setup plugins
local lazy = require('lazy')

lazy.setup({
  -- Auto-pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable('make') == 1 end,
      },
    },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      
      telescope.setup({
        defaults = {
          file_ignore_patterns = { '%.git/', '__pycache__/', '%.pyc' },
        },
      })
      
      if pcall(telescope.load_extension, 'fzf') then end -- Load FZF if available
      
      -- Consolidated keymaps
      local maps = {
        { '<leader>sf', builtin.find_files, 'Search files' },
        { '<leader>sg', builtin.live_grep, 'Search by grep' },
        { '<leader>sb', builtin.buffers, 'Search buffers' },
        { '<leader>sh', builtin.help_tags, 'Search help' },
        { '<leader>sd', builtin.diagnostics, 'Search diagnostics' },
      }
      for _, map in ipairs(maps) do
        vim.keymap.set('n', map[1], map[2], { desc = map[3] })
      end
    end,
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    ft = { 'python' }, -- Additional trigger for Python files
    dependencies = {
      'saghen/blink.cmp',
    },
    config = function()
      -- Diagnostics
      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = '●' },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '●',
            [vim.diagnostic.severity.WARN] = '●',
            [vim.diagnostic.severity.INFO] = '●',
            [vim.diagnostic.severity.HINT] = '●',
          },
        },
        float = { border = 'rounded' },
        update_in_insert = false,
        severity_sort = true,
      })

      -- LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          
          -- Use telescope for LSP functions
          local telescope_builtin = require('telescope.builtin')
          map('grd', telescope_builtin.lsp_definitions, 'Goto definition')
          map('grr', telescope_builtin.lsp_references, 'Goto references')
          map('gra', vim.lsp.buf.code_action, 'Code action')
          map('grn', vim.lsp.buf.rename, 'Rename')
          map('K', vim.lsp.buf.hover, 'Hover documentation')
          map('gD', vim.lsp.buf.declaration, 'Goto declaration')
        end,
      })

      -- Manual LSP management (no Mason) - Ruff + basedpyright installed manually

      -- Modern Python LSP setup: Ruff (primary) + Manual basedpyright (semantic tokens)
      local lspconfig = require('lspconfig')
      local blink = require('blink.cmp')
      
      local capabilities = blink.get_lsp_capabilities()
      
      -- Ruff LSP (primary) - handles linting, formatting, imports  
      local ruff_cmd = vim.fn.expand('~/.local/bin/ruff')
      if vim.fn.executable(ruff_cmd) == 1 then
        lspconfig.ruff.setup({
          cmd = { ruff_cmd, 'server' },
          capabilities = capabilities,
          init_options = {
            settings = {
              organizeImports = true,
              fixAll = true,
            },
          },
        })
      else
        vim.notify('Ruff LSP not found at: ' .. ruff_cmd, vim.log.levels.WARN)
      end
      
      -- Basedpyright setup with dynamic Python path
      local basedpyright_cmd = vim.fn.expand('~/.local/bin/basedpyright-langserver')
      if vim.fn.executable(basedpyright_cmd) == 1 then
        lspconfig.basedpyright.setup({
          cmd = { basedpyright_cmd, '--stdio' },
          capabilities = capabilities,
          single_file_support = true,
          before_init = function(_, config)
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.basedpyright = config.settings.basedpyright or {}
            config.settings.basedpyright.analysis = config.settings.basedpyright.analysis or {}
            
            local buffer_path = vim.api.nvim_buf_get_name(0)
            if not buffer_path or buffer_path == '' then
              buffer_path = vim.fn.getcwd() .. '/dummy.py'
            end
            
            local python_path = get_python_path(buffer_path)
            config.settings.python.pythonPath = python_path
            
            local project_root = find_project_root(vim.fn.fnamemodify(buffer_path, ':h'))
            if project_root then
              config.root_dir = project_root
            end
          end,
          settings = {
            basedpyright = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = 'workspace',
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,
                typeCheckingMode = 'basic',
                diagnosticSeverityOverrides = {
                  -- Disable diagnostics that Ruff handles
                  reportUnusedImport = 'none',
                  reportUnusedVariable = 'none',
                  reportUnusedFunction = 'none',
                  reportUnusedClass = 'none',
                  -- Reduce type checking severity
                  reportMissingTypeStubs = 'none',
                  reportMissingModuleSource = 'none',
                  reportGeneralTypeIssues = 'warning',
                  reportOptionalMemberAccess = 'warning',
                  reportAttributeAccessIssue = 'warning',
                  reportUnknownMemberType = 'none',
                },
              },
            },
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = 'workspace',
                useLibraryCodeForTypes = true,
              }
            }
          },
        })
      else
        vim.notify('Basedpyright LSP not found at: ' .. basedpyright_cmd, vim.log.levels.WARN)
      end
      
      -- Manual LSP management for minimal setup
      -- Ruff handles formatting and linting
    end,
  },

  -- Completion
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    dependencies = { 
      {
        'L3MON4D3/LuaSnip',
        build = 'make install_jsregexp',
        config = function()
          -- Essential Python snippets (loaded immediately for performance)
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
    },
  },

  -- Colorscheme
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      local tokyonight = require('tokyonight')
      
      -- Essential syntax highlighting overrides
      local function setup_syntax_highlighting(highlights, colors)
        -- Core Python highlights
        highlights['@variable'] = { fg = colors.soft_purple }
        highlights['@variable.parameter'] = { fg = colors.lavender }
        highlights['@variable.builtin'] = { fg = colors.mint_green, bold = true }
        highlights['@function'] = { fg = colors.calm_blue, bold = true }
        highlights['@function.builtin'] = { fg = colors.mint_green, bold = true }
        highlights['@function.builtin.python'] = { fg = colors.mint_green, bold = true }
        highlights['@type'] = { fg = colors.amethyst }
        highlights['@type.builtin'] = { fg = colors.warm_yellow, bold = true }
        highlights['@constructor'] = { fg = colors.coral, bold = true }
        highlights['@property'] = { fg = colors.cyan }
        highlights['@constant'] = { fg = colors.orange, bold = true }
        highlights['@string'] = { fg = colors.sage_green }
        highlights['@number'] = { fg = colors.orange }
        highlights['@boolean'] = { fg = colors.orange }
        highlights['@keyword'] = { fg = colors.warm_yellow, italic = true }
        highlights['@keyword.exception'] = { fg = colors.coral, italic = true }
        highlights['@operator'] = { fg = colors.warm_yellow }
        highlights['@comment'] = { fg = colors.slate_gray, italic = true }
        highlights['@module'] = { fg = colors.cyan }
        highlights['@field'] = { fg = colors.cyan }
        
        -- LSP semantic tokens (essential only)
        highlights['@lsp.type.class'] = { fg = colors.coral, bold = true }
        highlights['@lsp.type.function'] = { fg = colors.calm_blue, bold = true }
        highlights['@lsp.type.variable'] = { fg = colors.soft_purple }
        highlights['@lsp.type.parameter'] = { fg = colors.lavender }
        highlights['@lsp.mod.defaultLibrary'] = { fg = colors.mint_green, bold = true }
      end
      
      tokyonight.setup({
        style = 'night',
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = { bold = true },
        },
        on_colors = function(colors)
          -- TASTEFUL TOKYONIGHT PROFESSIONAL PALETTE (CONSOLIDATED)
          colors.soft_purple = '#bb9af7'     -- Variables (elegant, sophisticated)
          colors.calm_blue = '#7aa2f7'       -- Functions (professional, readable)
          colors.cyan = '#7dcfff'            -- Properties & modules (refined, soft)
          colors.warm_yellow = '#e0af68'     -- Keywords (tasteful, warm)
          colors.coral = '#f7768e'           -- Classes & errors (refined, pleasant)
          colors.sage_green = '#9ece6a'      -- Strings (natural, easy)
          colors.orange = '#ff9e64'          -- Numbers & special (warm, gentle)
          colors.slate_gray = '#565f89'      -- Comments (subtle, readable)
          colors.lavender = '#c0caf5'        -- Parameters (soft, distinctive)
          colors.mint_green = '#73daca'      -- Built-ins (fresh, professional)
          colors.amethyst = '#9d7cd8'        -- Types (rich, refined)
        end,
        on_highlights = setup_syntax_highlighting,
      })
      
      vim.cmd.colorscheme('tokyonight')
    end,
  },

  -- Statusline and utilities
  {
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      -- Statusline
      local statusline = require('mini.statusline')
      statusline.setup({ use_icons = false })
      
      -- Show Python environment in statusline
      statusline.section_filename = function()
        local buffer_path = vim.api.nvim_buf_get_name(0)
        if buffer_path ~= '' and buffer_path:match('%.py$') then
          local venv_name = extract_venv_name(get_python_path(buffer_path))
          return '(' .. venv_name .. ') %f%m%r'
        end
        return '%f%m%r'
      end
      
      -- Indent guides
      local indentscope = require('mini.indentscope')
      indentscope.setup({
        draw = { delay = 100, animation = indentscope.gen_animation.none() },
        mappings = {
          object_scope = 'ii',
          object_scope_with_border = 'ai',
          goto_top = '[i',
          goto_bottom = ']i',
        },
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
      local configs = require('nvim-treesitter.configs')
      
      configs.setup({
        ensure_installed = { 'python', 'lua', 'vim', 'vimdoc' },
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = true,
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
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
      plugin = '🔌', runtime = '💻', require = '🌙', source = '📄', start = '🚀',
      task = '📌', lazy = '💤 ',
    },
    border = 'rounded',
  },
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- vim: ts=2 sts=2 sw=2 et