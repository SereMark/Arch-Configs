--[[
═══════════════════════════════════════════════════════════════════════════════
                           LSP CONFIGURATION
                           
Optimized LSP setup for ML/AI development with enhanced Ruff and Basedpyright.
Perfectly balanced for Chess AI and scientific computing workflows.

Features:
- Enhanced Ruff LSP with ML-specific rules (NPY, PERF, FURB, PTH, ASYNC)
- Basedpyright with Union type handling and venv detection
- Smart diagnostic filtering for ML development patterns
- Performance-optimized capabilities
- Dynamic Python path detection integration
- Consolidated keymaps for AI development workflow
═══════════════════════════════════════════════════════════════════════════════
--]]

local M = {}

---Setup smart diagnostic configuration with filtering
local function setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = {
      spacing = 2,
      severity = { min = vim.diagnostic.severity.WARN },
      format = function(diagnostic)
        local msg = diagnostic.message
        -- Smart filtering for Python development
        if vim.bo.filetype == 'python' then
          if msg:match('may be undefined') or 
             (msg:match('Missing.*import') and vim.fn.expand('%:t'):match('^test_')) then
            return nil
          end
        end
        -- Truncate long messages for readability
        return #msg > 60 and msg:sub(1, 57) .. '...' or msg
      end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = 'E',
        [vim.diagnostic.severity.WARN] = 'W',
        [vim.diagnostic.severity.INFO] = 'I',
        [vim.diagnostic.severity.HINT] = 'H',
      },
    },
    float = { border = 'rounded' },
    update_in_insert = false,
    severity_sort = true,
    underline = {
      severity = { min = vim.diagnostic.severity.WARN },
    },
  })

  -- Optimize hover handler
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, { border = 'rounded' }
  )
end

---Setup LSP keymaps when LSP attaches to buffer
local function setup_lsp_keymaps()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
      local function map(keys, func, desc)
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
end

---Get optimized LSP capabilities
---@return table capabilities LSP client capabilities
local function get_lsp_capabilities()
  local blink = require('blink.cmp')
  local capabilities = blink.get_lsp_capabilities()
  
  -- Performance optimizations
  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.didChangeWatchedFiles = {
    dynamicRegistration = false,  -- Reduce file watching overhead
  }
  
  return capabilities
end

---Setup Ruff LSP for linting, formatting, and imports
---@param capabilities table LSP capabilities
local function setup_ruff_lsp(capabilities)
  local lspconfig = require('lspconfig')
  
  -- Find ruff executable
  local ruff_cmd = vim.fn.exepath('ruff')
  if ruff_cmd == '' then
    ruff_cmd = vim.fn.expand('~/.local/ruff-venv/bin/ruff')
  end
  
  if vim.fn.executable(ruff_cmd) ~= 1 then
    return false
  end
  
  lspconfig.ruff.setup({
    cmd = { ruff_cmd, 'server' },
    capabilities = capabilities,
    init_options = {
      settings = {
        organizeImports = true,
        fixAll = true,
        lint = {
          run = 'onSave',  -- Don't lint on every keystroke for performance
        },
      },
    },
    on_attach = function(client, bufnr)
      -- Disable hover in favor of basedpyright
      client.server_capabilities.hoverProvider = false
    end,
  })
  
  return true
end

---Setup Basedpyright LSP for type checking and completions
---@param capabilities table LSP capabilities
local function setup_basedpyright_lsp(capabilities)
  local lspconfig = require('lspconfig')
  local python_env = require('python-env')
  
  -- Find basedpyright executable
  local basedpyright_cmd = vim.fn.exepath('basedpyright-langserver')
  if basedpyright_cmd == '' then
    basedpyright_cmd = vim.fn.expand('~/.local/basedpyright-venv/bin/basedpyright-langserver')
  end
  
  if vim.fn.executable(basedpyright_cmd) ~= 1 then
    return false
  end
  
  lspconfig.basedpyright.setup({
    cmd = { basedpyright_cmd, '--stdio' },
    capabilities = capabilities,
    single_file_support = true,
    flags = {
      debounce_text_changes = 750,  -- Optimized debounce for performance
    },
    before_init = function(_, config)
      -- Initialize settings structure
      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.basedpyright = config.settings.basedpyright or {}
      config.settings.basedpyright.analysis = config.settings.basedpyright.analysis or {}
      
      -- Get current buffer path for context
      local buffer_path = vim.api.nvim_buf_get_name(0)
      if not buffer_path or buffer_path == '' then
        buffer_path = vim.fn.getcwd() .. '/dummy.py'
      end
      
      -- Set Python path based on detected environment
      local python_path = python_env.get_python_path(buffer_path)
      config.settings.python.pythonPath = python_path
      
      -- Set project root
      local project_root = python_env.find_project_root(vim.fn.fnamemodify(buffer_path, ':h'))
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
          -- Enhanced diagnostic settings inherited from pyrightconfig.json
          -- Optimized for ML/AI development with Union type handling
        },
      },
    },
  })
  
  return true
end

---Setup all LSP configurations
function M.setup()
  -- Setup diagnostics first
  setup_diagnostics()
  
  -- Setup LSP keymaps
  setup_lsp_keymaps()
  
  -- Get optimized capabilities
  local capabilities = get_lsp_capabilities()
  
  -- Setup both LSP servers silently
  setup_ruff_lsp(capabilities)
  setup_basedpyright_lsp(capabilities)
end


return M