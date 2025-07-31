vim.g.mapleader = ' '
vim.loader.enable()

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.laststatus = 0
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4
vim.opt.clipboard = 'unnamedplus'
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.completeopt = 'menu,menuone,noselect,fuzzy'
vim.opt.pumheight = 15
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevelstart = 99

local plugins = { 'ibhagwan/fzf-lua', 'folke/tokyonight.nvim', 'nvim-treesitter/nvim-treesitter' }

vim.iter(plugins):each(function(repo)
  local name = repo:match('([^/]+)$')
  local path = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'plugins', 'start', name)
  if not vim.uv.fs_stat(path) then
    vim.fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/' .. repo, path })
  end
end)

local fzf = require('fzf-lua')
fzf.setup({
  files = {
    fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude build --exclude cmake-build-* --exclude _build --exclude out --exclude dist --exclude node_modules",
  },
  grep = {
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g '!build/' -g '!cmake-build-*/' -g '!_build/' -g '!out/' -g '!dist/' -g '!node_modules/' -e",
  }
})
vim.keymap.set('n', '<leader>sf', fzf.files)
vim.keymap.set('n', '<leader>sg', fzf.live_grep)
vim.keymap.set('n', '<leader>sb', fzf.buffers)
vim.keymap.set('n', '<leader>sh', fzf.help_tags)
vim.keymap.set('n', '<leader>ss', fzf.lsp_document_symbols)

pcall(vim.cmd.colorscheme, 'tokyonight')

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'lua', 'vim', 'c', 'cpp', 'cmake', 'make' },
  highlight = { 
    enable = true,
    additional_vim_regex_highlighting = false,
    disable = function(_, buf)
      local max_filesize = 100 * 1024
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      return ok and stats and stats.size > max_filesize
    end,
  },
  indent = { enable = true },
  fold = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      node_incremental = '<CR>',
      scope_incremental = '<S-CR>',
      node_decremental = '<BS>',
    },
  },
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local root_dir = vim.fs.root(0, { '.git', 'CMakeLists.txt', 'Makefile', 'compile_commands.json' }) or vim.uv.cwd()
    
    vim.lsp.config('*', {
      on_attach = function(client, bufnr)
        if not client.supports_method('textDocument/documentHighlight') then return end
        
        local group = vim.api.nvim_create_augroup('LSPDocumentHighlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = bufnr,
          group = group,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = bufnr,
          group = group,
          callback = vim.lsp.buf.clear_references,
        })
      end,
      capabilities = {
        textDocument = {
          completion = {
            completionItem = {
              snippetSupport = true,
              resolveSupport = { properties = { 'documentation', 'detail', 'additionalTextEdits' } }
            }
          },
          foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
          semanticTokens = { multilineTokenSupport = false }
        }
      }
    })
    
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local buf = event.buf
        
        if client.supports_method('textDocument/completion') then
          vim.lsp.completion.enable(true, event.data.client_id, buf, { 
            autotrigger = true,
            convert = function(item)
              if item.kind == vim.lsp.protocol.CompletionItemKind.Snippet then
                item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
              end
              return item
            end
          })
        end
        
        if client.supports_method('textDocument/inlayHint') then
          vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        end
        
        if client.supports_method('textDocument/semanticTokens') then
          client.server_capabilities.semanticTokensProvider = vim.empty_dict()
        end
        
        local map = function(keys, func) vim.keymap.set('n', keys, func, { buffer = buf }) end
        map('K', vim.lsp.buf.hover)
        map('gd', vim.lsp.buf.definition)
        map('gD', vim.lsp.buf.declaration)
        map('gi', vim.lsp.buf.implementation)
        map('gt', vim.lsp.buf.type_definition)
        map('gr', vim.lsp.buf.references)
        map('<leader>rn', vim.lsp.buf.rename)
        map('<leader>ca', vim.lsp.buf.code_action)
        map('<leader>f', function() vim.lsp.buf.format({ async = true }) end)
        map('[d', vim.diagnostic.goto_prev)
        map(']d', vim.diagnostic.goto_next)
        map('<leader>e', vim.diagnostic.open_float)
        map('<leader>dl', vim.diagnostic.setloclist)
      end
    })

    if vim.fn.executable('clangd') == 1 then
      vim.lsp.config('clangd', {
        cmd = { 
          'clangd',
          '--background-index',
          '--background-index-priority=normal',
          '--clang-tidy',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--header-insertion=iwyu',
          '--header-insertion-decorators',
          '--pch-storage=memory',
          '--pretty',
          '--all-scopes-completion',
          '--log=error'
        },
        root_dir = root_dir,
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
          fallbackFlags = { '-std=c++20' }
        },
        settings = {
          clangd = {
            InlayHints = {
              Designators = true,
              Enabled = true,
              ParameterNames = true,
              DeducedTypes = true,
            },
            completion = { AllScopes = true }
          }
        }
      })
      vim.lsp.enable({ 'clangd' })
    end
  end
})

vim.filetype.add({
  extension = {
    hpp = 'cpp', hxx = 'cpp', cxx = 'cpp', tpp = 'cpp', ipp = 'cpp',
    cuh = 'cuda', cu = 'cuda',
  },
  filename = {
    ['CMakeLists.txt'] = 'cmake',
    ['.clangd'] = 'yaml',
    ['.clang-format'] = 'yaml',
  }
})

vim.diagnostic.config({
  virtual_text = { prefix = '●', source = true, spacing = 2 },
  virtual_lines = false,
  float = { source = true, border = 'rounded', header = '', prefix = '', focusable = false },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '▲',
      [vim.diagnostic.severity.HINT] = '⚑',
      [vim.diagnostic.severity.INFO] = '»',
    }
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_create_user_command('DiagnosticsToggleVirtualText', function()
  local config = vim.diagnostic.config()
  vim.diagnostic.config({ virtual_text = not config.virtual_text })
end, { desc = 'Toggle diagnostic virtual text' })

vim.api.nvim_create_user_command('DiagnosticsToggleVirtualLines', function()
  local config = vim.diagnostic.config()
  vim.diagnostic.config({ virtual_lines = not config.virtual_lines })
end, { desc = 'Toggle diagnostic virtual lines' })