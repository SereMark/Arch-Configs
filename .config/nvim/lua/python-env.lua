--[[
═══════════════════════════════════════════════════════════════════════════════
                         PYTHON ENVIRONMENT DETECTION
                         
Intelligent Python environment detection and LSP configuration.
Supports virtualenv, conda, pyenv with smart caching and cross-platform paths.

Features:
- Automatic virtualenv detection (venv, .venv, conda, pyenv)
- Smart project root detection
- LSP configuration updates
- Cross-platform compatibility
- Performance-optimized caching (5min TTL)
- Comprehensive error handling
═══════════════════════════════════════════════════════════════════════════════
--]]

local M = {}

-- Configuration
local CONFIG = {
  cache_ttl = 300, -- 5 minutes
  project_markers = { '.git', 'requirements.txt', 'setup.py', 'Pipfile', 'pyproject.toml' },
  venv_names = { 'venv', '.venv', 'env', '.env' },
  projects_dir = vim.env.PROJECTS_DIR or (vim.env.HOME .. '/projects'),
}

-- Cache storage
local python_path_cache = {}
local cache_timestamp = {}
local current_python_path = nil

---Safely check if a file or directory exists
---@param path string
---@return boolean
local function path_exists(path)
  if not path or path == '' then return false end
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

---Find project root by searching for project markers
---@param start_path string|nil Starting directory path
---@return string|nil project_root Project root path or nil if not found
function M.find_project_root(start_path)
  local current = start_path or vim.fn.getcwd()
  if not current or current == '' then return nil end
  
  -- Normalize path separators for cross-platform compatibility
  current = vim.fn.resolve(current)
  local projects_dir = vim.fn.resolve(CONFIG.projects_dir)
  
  -- Check if we're in projects directory tree
  if current:find(projects_dir, 1, true) == 1 then
    -- Look for project root markers (not config files)
    local search_path = current
    while search_path ~= '/' and search_path ~= projects_dir do
      for _, marker in ipairs(CONFIG.project_markers) do
        local marker_path = search_path .. '/' .. marker
        if path_exists(marker_path) then
          return search_path
        end
      end
      search_path = vim.fn.fnamemodify(search_path, ':h')
    end
    return projects_dir -- Fallback to projects dir
  end
  
  -- Standard behavior for paths outside projects directory
  while current ~= '/' and current ~= '' do
    for _, marker in ipairs(CONFIG.project_markers) do
      local marker_path = current .. '/' .. marker
      if path_exists(marker_path) then
        return current
      end
    end
    current = vim.fn.fnamemodify(current, ':h')
  end
  
  return nil
end

---Extract virtual environment name from Python path
---@param python_path string|nil Python executable path
---@return string venv_name Environment name or 'system'
local function extract_venv_name(python_path)
  if not python_path or python_path == '' then return 'system' end
  local venv_name = python_path:match('/([^/]+)/bin/python[%d%.]*$')
  return venv_name or 'system'
end

---Get Python path with intelligent environment detection and caching
---@param buffer_path string|nil Buffer file path for context
---@return string python_path Python executable path
function M.get_python_path(buffer_path)
  local start_dir = buffer_path and vim.fn.fnamemodify(buffer_path, ':h') or vim.fn.getcwd()
  
  -- Check cache with TTL
  local now = os.time()
  if python_path_cache[start_dir] and cache_timestamp[start_dir] and
     (now - cache_timestamp[start_dir]) < CONFIG.cache_ttl then
    return python_path_cache[start_dir]
  end
  
  local python_path
  
  -- 1. Use activated virtualenv (highest priority)
  if vim.env.VIRTUAL_ENV then
    local venv_python = vim.env.VIRTUAL_ENV .. '/bin/python'
    if path_exists(venv_python) then
      python_path = venv_python
    end
  end
  
  -- 2. Find project root and check for local venv
  if not python_path then
    local project_root = M.find_project_root(start_dir)
    if project_root then
      for _, venv_name in ipairs(CONFIG.venv_names) do
        local venv_python = project_root .. '/' .. venv_name .. '/bin/python'
        if path_exists(venv_python) then
          python_path = venv_python
          break
        end
      end
    end
  end
  
  -- 3. Check for pyenv (with error handling)
  if not python_path then
    local ok, result = pcall(vim.fn.system, 'pyenv which python 2>/dev/null')
    if ok and vim.v.shell_error == 0 and result and result:match('%S') then
      python_path = result:gsub('%s+', '')
    end
  end
  
  -- 4. Check for conda
  if not python_path and vim.env.CONDA_PREFIX then
    local conda_python = vim.env.CONDA_PREFIX .. '/bin/python'
    if path_exists(conda_python) then
      python_path = conda_python
    end
  end
  
  -- 5. Default to system Python
  if not python_path then
    python_path = vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python3'
  end
  
  -- Cache the result with timestamp
  if python_path and python_path ~= '' then
    python_path_cache[start_dir] = python_path
    cache_timestamp[start_dir] = now
  end
  
  return python_path
end

---Update LSP Python configuration when environment changes
---@param buffer_path string|nil Buffer file path
function M.update_python_lsp(buffer_path)
  local new_python_path = M.get_python_path(buffer_path)
  
  if current_python_path ~= new_python_path then
    current_python_path = new_python_path
    
    -- Update basedpyright LSP client
    for _, client in pairs(vim.lsp.get_clients()) do
      if client.name == 'basedpyright' and client.config and client.config.settings then
        client.config.settings.python = client.config.settings.python or {}
        client.config.settings.python.pythonPath = new_python_path
        
        -- Safely notify the LSP server
        pcall(client.notify, 'workspace/didChangeConfiguration', {
          settings = client.config.settings
        })
      end
    end
    
    -- Silent environment change (no notifications during normal operation)
  end
end

---Setup Python-specific configuration and keymaps
---@param buf number Buffer handle
function M.setup_python_buffer(buf)
  -- Python settings (consolidated)
  vim.bo[buf].textwidth = 88
  vim.bo[buf].expandtab = true
  vim.bo[buf].shiftwidth = 4
  vim.bo[buf].softtabstop = 4
  vim.bo[buf].tabstop = 4
  vim.wo.foldmethod = 'indent'
  vim.wo.foldlevel = 99
  
  -- Update Python LSP for this project
  local buffer_path = vim.api.nvim_buf_get_name(buf)
  if buffer_path ~= '' then
    local new_python_path = M.get_python_path(buffer_path)
    if current_python_path ~= new_python_path then
      M.update_python_lsp(buffer_path)
    end
  end
  
  -- Python keymaps (streamlined)
  local function map(key, func, desc)
    vim.keymap.set('n', key, func, { buffer = buf, silent = true, desc = desc })
  end
  
  -- Test runner (optimized to use detected Python)
  map('<leader>t', function()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == '' then return end
    
    local python_path = M.get_python_path(file)
    local cmd = file:match('test.*%.py$') 
      and { python_path, '-m', 'pytest', file } 
      or { python_path, file }
    
    vim.system(cmd, { text = true }, function(result)
      local message = result.code == 0 and 'Execution completed' 
        or 'Execution failed: ' .. (result.stderr or result.stdout or 'Unknown error')
      local level = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      vim.notify(message, level)
    end)
  end, 'Run Python file/test')
  
  -- REPL integration (optimized to use detected Python)
  map('<leader>r', function()
    local line = vim.api.nvim_get_current_line()
    if line:match('%S') then
      local file = vim.api.nvim_buf_get_name(buf)
      local python_path = M.get_python_path(file)
      
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
end


return M