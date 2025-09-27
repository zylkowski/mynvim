-- MY FUCKING INIT ~Arek
local utils = require 'utils'

-- TODO:
-- - rust-analyzer only works when in .rs file. I'd like it to work already when in folder with Cargo.toml
vim.g.mapleader = ' ' -- Set <space> as the leader key
vim.g.maplocalleader = ' ' --- Set <space> as the local leader key
vim.g.have_nerd_font = true -- Set to true if you have a Nerd Font installed

-- Sync clipboard between OS and Neovim.
-- Remove this option if you want your OS clipboard to remain independent.
vim.opt.clipboard = 'unnamedplus' --  See `:help 'clipboard'`
-- vim.opt.updatetime = 80 -- update time
-- vim.opt.timeoutlen = 80 -- Decrease mapped sequence wait time : Displays which-key popup sooner
-- if you don't use whichkey then use times below
vim.opt.updatetime = 250 -- update time

vim.opt.timeoutlen = 1000
vim.cmd 'autocmd InsertLeave * set timeoutlen=1000'
vim.cmd 'autocmd InsertEnter * set timeoutlen=0'

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true -- yes use tempr gui colors
vim.opt.wrap = false -- don't wrap lines
vim.opt.mouse = 'a' -- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.showmode = false -- Don't show the mode, since it's already in status line
vim.opt.breakindent = true -- Enable break indent
vim.opt.undofile = true -- Save undo history
vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- ... actually lets make it sensitive if an upper case is involved
vim.opt.smartindent = true -- ... smart indentation --- need to figure out what to do, want vscode like auto indenting when opening a function or { ... local foo = function() <cr> does not indend body of function in lua for instance
vim.opt.signcolumn = 'yes' -- Keep signcolumn on by default
vim.opt.splitright = true -- Configure how new splits should be opened
vim.opt.splitbelow = true
vim.opt.list = true -- Sets how neovim will display certain whitespace in the editor.
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split' -- Preview substitutions live, as you type!
vim.opt.cursorline = true -- Show which line your cursor is on
vim.opt.scrolloff = 16 -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.hlsearch = true -- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.numberwidth = 3
vim.opt.autoread = true
vim.opt.laststatus = 3 -- better looking horizontal window split borders
vim.opt.fillchars:append { diff = '' } -- { diff = '/' } -- fillchars for diffview?
-- vim.o.autochdir = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.filetype.add {
  extension = {
    bend = 'bend',
  },
}

vim.diagnostic.config {
  virtual_text = false,
  float = { scope = 'l' },
  severity_sort = true,
}

-- My dumb custom workspac linting thing
-- NOTE: currently only set up for tsc + eslint in a node.js project
vim.api.nvim_create_user_command('Lint', function()
  local runner = require 'lint-runner'

  -- run tsc and eslint in parallel
  local tsc = require 'linters_tsc'
  local eslint = require 'linters_eslint'
  runner.run_linter(tsc)
  runner.run_linter(eslint)
end, { desc = 'workspace lint' })

vim.keymap.set('n', '<leader>F', function()
  local runner = require 'lint-runner'

  local namespaces = runner.get_namespaces()

  local pos = vim.api.nvim_win_get_cursor(0)
  local lnum = pos[1] - 1

  for _, namespace in ipairs(namespaces) do
    local rem_diagnostics = vim.tbl_filter(function(e)
      return e.lnum ~= lnum
    end, vim.diagnostic.get(0, { namespace = namespace }))
    vim.diagnostic.reset(namespace, 0)
    vim.diagnostic.set(namespace, 0, rem_diagnostics)
  end
end, { desc = 'LINT mark as [F]ixed' })

vim.api.nvim_create_user_command('Arr', utils.arr, { nargs = 1 })

--========================= KEYMAPS =======================
require 'ollama'

--========================= ESC BINDINGS ==================
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { silent = true })
vim.keymap.set('i', '<Esc>]', '<Space>', { noremap = true, silent = true })

vim.api.nvim_create_user_command('RenameTerminal', utils.rename_terminal_to_last_command, {})
vim.keymap.set('t', '<Enter>', '<Enter><C-\\><C-n>:RenameTerminal<Enter>a', { silent = true })
vim.keymap.set('t', '<C-q><Esc>', '<Esc>', { silent = true })

vim.keymap.set('n', '<leader>w', function()
  vim.wo.wrap = not vim.wo.wrap
  print('Line wrap: ' .. (vim.wo.wrap and 'ON' or 'OFF'))
end, { desc = 'Toggle line wrapping' })

vim.keymap.set('n', 'U', '<cmd>earlier 1f<cr>', { desc = 'undo all the way to previous (earlier) save' })
vim.keymap.set('n', 'W', '<cmd>later 1f<cr>', { desc = 'redo all the way to later save' })

-- dont insert comment when pressed 'o' or 'O' in normal mode when cursor is on comment
vim.cmd 'autocmd InsertLeave * set formatoptions-=cro'
vim.cmd 'autocmd InsertLeave * setlocal formatoptions-=cro'

vim.cmd 'autocmd InsertEnter * set formatoptions+=cro'
vim.cmd 'autocmd InsertEnter * setlocal formatoptions+=cro'

vim.keymap.set('v', '<leader>sc', '"hy:%s/<C-r>h//gc<left><left><left>', { desc = '[S]ubstitute [C]hange' })
vim.keymap.set('v', '<leader>sa', '"hy:%s/<C-r>h/<C-r>h/gc<left><left><left>', { desc = '[S]ubstitute [A]ppend' })
vim.keymap.set('v', '<leader>ss', ':s/\\%V', { desc = '[S]ub[s]titute' })

-- NOTE: like * but doesn't move you around
vim.keymap.set('n', '*', '/<C-R><C-W><cr>N', { desc = 'highlight all occurrences of current word' })
-- vim.keymap.set('n', '<C-q>', '<C-v>')

vim.keymap.set('n', '<C-w>n', ':tabnew<cr>:terminal<cr>i', { desc = '[N]ew tab' })

vim.keymap.set('n', '<C-w>\\', function()
  vim.cmd(math.floor(vim.fn.winwidth(0) * 0.45) .. 'vsplit')
  vim.cmd 'terminal'
end, { desc = 'Vertical split' })

vim.keymap.set('n', '<C-w><C-w>\\', function()
  vim.cmd(math.floor(vim.fn.winwidth(0) * 0.45) .. 'vsplit')
end, { desc = 'Vertical split same file' })

vim.keymap.set('n', '<C-w>-', function()
  vim.cmd(math.floor(vim.fn.winheight(0) * 0.35) .. 'split')
  vim.cmd 'terminal'
end, { desc = 'Horizontal split' })

vim.keymap.set('n', '<C-w><C-w>-', function()
  vim.cmd(math.floor(vim.fn.winheight(0) * 0.35) .. 'split')
end, { desc = 'Horizontal split same file' })

vim.keymap.set('t', '<esc>', '<C-\\><C-n>')

-- windows navigation
vim.keymap.set('n', '<Left>', '<C-w>h')
vim.keymap.set('n', '<Right>', '<C-w>l')
vim.keymap.set('n', '<Down>', '<C-w>j')
vim.keymap.set('n', '<Up>', '<C-w>k')

-- resizing windows
vim.keymap.set({ 'v', 'n' }, '<M-y>', '<C-w>3-')
vim.keymap.set({ 'v', 'n' }, '€', '<C-w>3<')
vim.keymap.set({ 'v', 'n' }, '<M-i>', '<C-w>3>')
vim.keymap.set({ 'v', 'n' }, 'ó', '<C-w>3+')

vim.keymap.set({ 'v', 'n' }, '<M-h>', ':tabp<CR>')
vim.keymap.set({ 'v', 'n' }, 'ł', ':tabn<CR>') -- <M-l> on polish keyboard

-- unbind default grn gra grr
vim.keymap.del('n', 'grn')
vim.keymap.del({ 'n', 'x' }, 'gra')
vim.keymap.del('n', 'grr')

-- vim.keymap.set('n', '<M-j>', '12j')
-- vim.keymap.set('n', '<M-k>', '12k')
do
  local dt = 8
  local n = 20

  --- @param dir 'j' | 'k'
  local function jump(dir)
    return function()
      local d = vim.api.nvim_get_mode()
      local wh = vim.api.nvim_win_get_height(vim.api.nvim_get_current_win())
      local dn = n * wh / (2 * 68)
      for i = 0, dn do
        vim.fn.timer_start(i * dt, function()
          vim.api.nvim_feedkeys(dir, d.mode, false)
        end)
      end
    end
  end

  vim.keymap.set({ 'v', 'n' }, '<M-j>', jump 'j')
  vim.keymap.set({ 'v', 'n' }, '<M-k>', jump 'k')
end

local quickfix = require 'quickfix'
vim.keymap.set('n', '<leader>qo', ':cwindow<cr><C-W>J', { desc = 'Open [Q]uickfix list' })
vim.keymap.set('n', '<leader>qc', ':ccl<CR>', { desc = '[Q]uickfix [C]lose' })
vim.keymap.set('n', '<leader>qp', quickfix.put, { desc = '[Q]uickfix [P]ut' })
vim.keymap.set('n', '<leader>qd', quickfix.delete, { desc = '[Q]uickfix [D]elete entry' })
vim.keymap.set('n', '<leader>qr', ':cexpr []<cr>', { desc = '[Q]uickfix [R]remove list' })
vim.keymap.set('n', '<leader>qm', ':MarksQFListAll<cr>', { desc = '[Q]uickifx list add all [M]arks' })
vim.keymap.set('n', ']q', ':cn<cr>', { desc = 'Go to next [Q]uickfix list' })
vim.keymap.set('n', '[q', ':cp<cr>', { desc = 'Go to next [Q]uickfix list' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

-- NOTE: swap lines like in vscode
--
--   we've bound <M-*> so the `Alt` or `Modifier` key, however, see :h :map-alt and you'll notice that
--   nvim is not able to distinguish between `Esc` and `Alt` if key press is fast enough, we'll just live
--   with this, it rarely causes issues, but if you press `Esc` + j  or `Esc + k` very quickly while
--   in normal mode, you'll also trigger the below keymaps.
vim.keymap.set('n', '<C-k>', ':m-2<cr>', { desc = 'swap line with line above' }) -- vscode <alt> + <down>
vim.keymap.set('n', '<C-j>', ':m+1<cr>', { desc = 'swap line with line below' }) -- vscode <alt> + <up>

-- useful for figuring out what higlight groups are relevant for stuff under cursor
vim.keymap.set('n', '<leader>I', function()
  vim.show_pos()
end, { desc = '[I]nspect higlight groups' })

-- Nice to start off where you left off
vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Start off where you left off',
  group = vim.api.nvim_create_augroup('kickstart-buf-enter', { clear = true }),
  -- NOTE: this is just the command '"  in lua [[ and ]] are similar to ``` in other languages
  callback = function()
    local ok, pos = pcall(vim.api.nvim_buf_get_mark, 0, [["]])
    if ok and pos[1] > 0 then
      -- protected mode because sometimes this will fail, for example on NON FILE BUFFERS
      pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end
  end,
})

vim.api.nvim_command 'augroup terminal_setup | au!'
-- vim.api.nvim_command 'autocmd TermOpen * nnoremap <buffer><LeftRelease> <LeftRelease>i'
vim.api.nvim_command 'augroup end'

vim.api.nvim_create_autocmd({ 'TermEnter', 'TermLeave' }, {
  callback = function()
    vim.cmd 'Fidget suppress'
  end,
})

-- OSC7 support
require 'osc7'

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- =================================== HEX COLORS =============================

require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  {
    'mbbill/undotree', -- Nice file change history
    config = function()
      vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>:UndotreeFocus<CR>', { desc = 'Toggle [U]ndotree' })
    end,
  },
  {
    'chentoast/marks.nvim',
    opts = {},
  },
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    -- branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      'nvim-telescope/telescope-symbols.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          layout_config = {
            width = 0.9,
            height = 0.9,
          },
          mappings = {
            i = {
              ['<c-f>'] = 'to_fuzzy_refine',
              ['<Esc>'] = require('telescope.actions').close,
              -- ['<Right>'] = require('telescope.actions').select_default,
              ['<c-e>'] = require('telescope.actions').delete_buffer,
            },
            n = {
              ['<Esc>'] = require('telescope.actions').close,
              -- ['<Right>'] = require('telescope.actions').select_default,
              ['<c-e>'] = require('telescope.actions').delete_buffer,
            },
          },
          cache_picker = {
            num_pickers = 10,
          },
        },
        pickers = {},
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local telescope = require 'telescope'
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local sorters = require 'telescope.sorters'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      -- Register the extension under the name "my_history"
      telescope.extensions = telescope.extensions or {}
      telescope.extensions.shell_history = {
        shell = function()
          local history_file = vim.fn.expand '~/.bash_history' -- or ~/.bash_history
          local seen = {}
          local lines = {}

          for line in io.lines(history_file) do
            line = line:gsub('^: [^;]*; ', '')
            if not seen[line] then
              seen[line] = true
              table.insert(lines, line)
            end
          end

          pickers
            .new({}, {
              prompt_title = 'Shell History',
              finder = finders.new_table { results = lines },
              sorter = sorters.fuzzy_with_index_bias(),
              attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)
                  if selection then
                    vim.api.nvim_put({ selection[1] }, 'c', true, true)
                  end
                end)
                return true
              end,
            })
            :find()
        end,
      }

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>st', telescope.extensions.shell_history.shell, { desc = '[S]earch [T]erminal' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', function()
        builtin.find_files { find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } } --hidden = true
      end, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sF', function()
        builtin.find_files { find_command = { 'rg', '--files', '--hidden', '--no-ignore' } } --hidden = true
      end, { desc = '[S]earch all [F]iles' })

      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sc', builtin.git_status, { desc = '[S]earch git [C]changes' })
      vim.keymap.set('n', '<leader>sdd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sde', function()
        builtin.diagnostics { severity = vim.diagnostic.severity.ERROR }
      end, { desc = '[S]earch [D]iagnostics [E]rror' })
      vim.keymap.set('n', '<leader>sdw', function()
        builtin.diagnostics { severity = vim.diagnostic.severity.WARN }
      end, { desc = '[S]earch [D]iagnostics [W]arning' })
      vim.keymap.set('n', '<leader>sr', builtin.pickers, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sl', builtin.highlights, { desc = '[S]earch High[L]ights' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          -- previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      sign_priority = 9,
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 200,
      },
    },
    init = function()
      -- hunks
      vim.keymap.set('n', ']h', ':Gitsigns next_hunk<cr>', { desc = 'Git Next hunk' })
      vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<cr>', { desc = 'Git Prev diff hunk' })

      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<cr>', { desc = '[G]it [P]review hunk' })
      vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<cr>', { desc = '[G]it [R]eset hunk' })
      vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame<CR>', { desc = '[G]it line [B]lame toggle' })
      vim.keymap.set('n', '<leader>gB', ':Gitsigns blame<CR>', { desc = '[G]it entire [B]lame toggle' })
      vim.keymap.set('n', '<leader>dt', ':Gitsigns diffthis<cr>', { desc = 'See changes in the current buffer' })
    end,
  },
  {
    'sindrets/diffview.nvim',
    dependencies = {
      'nvim-web-devicons',
    },
    opts = {
      -- enhanced_diff_hl = true,
      hooks = {
        view_opened = function()
          -- print 'opening view'
          vim.fn.timer_start(100, function()
            local tp = vim.api.nvim_get_current_tabpage()
            local wins = vim.api.nvim_tabpage_list_wins(tp)
            local win = wins[3]

            local buf = vim.api.nvim_win_get_buf(wins[3])
            if utils.buf_is_trivial(buf) then
              print 'no change'
              -- vim.cmd [[:DiffviewClose]]
              return
            end

            if win then
              vim.api.nvim_set_current_win(win)
              vim.api.nvim_win_set_cursor(0, { 1, 0 })
            end
          end)
        end,
      },
    },
    init = function()
      vim.keymap.set('n', '<leader>gd', function()
        -- first we get current cursor location in the file we're in
        local pos = vim.api.nvim_win_get_cursor(0)

        vim.cmd [[:DiffviewOpen]]
        vim.fn.timer_start(
          100, -- delay ms ... increase this if you dont see desired result
          function()
            -- this delayed callback is optional
            -- it effectively goes to where you were in the file
            -- NOTE at this point in "time" our current window
            --      is the the active window in the diffview, diffview hooks may impact which window this is

            if utils.buf_is_trivial(0) then
              print 'no changes'
              -- vim.cmd [[:DiffviewClose]]
              return
            end

            local n = vim.api.nvim_buf_line_count(0)

            if pos[1] <= n then
              vim.api.nvim_win_set_cursor(0, pos) -- note that 0 -> current window which is now the diff window after 100 ms
              vim.api.nvim_feedkeys('zz', 'n', false)
            end
          end
        )
      end, {
        desc = '[G]it [D]iff',
      })
    end,
  },
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/lazydev.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype definition')

          map('gr', function()
            require('telescope.builtin').lsp_references { show_line = false }
          end, '[G]oto [R]eferences')

          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>sw', require('telescope.builtin').lsp_workspace_symbols, '[S]earch [W]orkspace Symbols')

          -- map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>rn', function()
            local cursor_pos = vim.api.nvim_win_get_cursor(0)

            local hover_res = vim.lsp.buf_request_sync(0, 'textDocument/hover', vim.lsp.util.make_position_params(), 200)

            if not hover_res then
              vim.print 'No hover result for rename'
              return
            end

            local hover = hover_res[1]

            if hover and not hover.error and hover.result and hover.result.range then
              --- @class I.Loc
              --- @field character integer
              --- @field line integer

              local file_buf = vim.api.nvim_get_current_buf()

              local s = hover.result.range['start'] --- @type I.Loc
              local e = hover.result.range['end'] --- @type I.Loc
              local old_name = vim.api.nvim_buf_get_text(0, s.line, s.character, e.line, e.character, {})[1]

              local row = vim.fn.winline()
              local col = vim.fn.wincol()
              local buf = vim.api.nvim_create_buf(false, true)
              local win = vim.api.nvim_open_win(buf, false, {
                relative = 'win',
                title = ' new name ',
                row = row,
                col = col,
                width = 25,
                height = 1,
                border = 'rounded',
                style = 'minimal',
              })

              vim.api.nvim_set_current_win(win)
              vim.api.nvim_buf_set_lines(0, 0, 2, false, { old_name })
              vim.keymap.set({ 'n' }, '<Esc><Esc>', ':q<cr>', { buffer = buf })
              vim.keymap.set({ 'n', 'i' }, '<cr>', function()
                local new_name = vim.api.nvim_buf_get_text(0, 0, 0, 0, 256, {})[1]
                vim.api.nvim_win_close(win, true)
                if new_name == old_name then
                  print 'no change'
                  return
                end
                if #new_name == 0 then
                  print 'cannot name to empty string'
                  return
                end

                -- custom handler to avoid race conditions, we want to do some extra
                -- pos renaming logic, like going back to normal mode, and positioning
                -- the cursor where it was
                local original_handler = vim.lsp.handlers['textDocument/rename']
                vim.lsp.handlers['textDocument/rename'] = function(err, result, ctx, config)
                  if original_handler then
                    original_handler(err, result, ctx, config)
                  end
                  if not err and result then
                    vim.cmd.stopi()
                    cursor_pos[2] = cursor_pos[2] + 1
                    vim.api.nvim_win_set_cursor(0, cursor_pos)
                  end
                  vim.lsp.handlers['textDocument/rename'] = original_handler
                end
                vim.lsp.buf.rename(new_name, { bufnr = file_buf })
              end, { buffer = buf })
            end
          end, '[R]e[n]ame')

          -- map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: [C]ode [A]ction' })
          vim.keymap.set('i', '<C-x>', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: Code Action' })

          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- wraps normal diagnostics callback so we can get some extra information
          -- useful to tell whether or not we are still loading workspace
          vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, res, ctx)
            local uri = res.uri
            require('fidget').notify('-> ', '@comment.error', { key = 'diagnostic', annote = uri })
            vim.lsp.diagnostic.on_publish_diagnostics(err, res, ctx)
          end

          vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = 'single',
          })

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })
      -- vim.api.nvim_create_autocmd('BufEnter', {
      --   pattern = '*.rs',
      --   callback = function()
      --     local params = vim.lsp.util.make_position_params()
      --
      --     -- Trigger hover (safe no-op)
      --     vim.lsp.buf_request(0, 'textDocument/hover', params, function() end)
      --
      --     -- Optionally trigger documentSymbol too (slightly more expensive)
      --     vim.lsp.buf_request(0, 'textDocument/documentSymbol', { textDocument = { uri = vim.uri_from_bufnr(0) } }, function() end)
      --   end,
      -- })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        -- clangd = {},
        -- gopls = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'strict',
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                  reportUnknownMemberType = 'none',
                  reportPrivateImportUsage = 'none',
                },
              },
            },
          },
        },
        ts_ls = {},
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              -- check = {
              --   command = 'clippy',
              -- },
              diagnostics = {
                enable = true,
                -- experimental = {
                --   enable = true,
                -- },
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              runtime = {
                version = 'LuaJIT',
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.api.nvim_get_runtime_file('', true),
                },
              },
              diagnostics = {
                globals = { 'vim' },
                disable = { 'redefined-local' },
              },
              -- telemetry = {
              --   enable = false,
              -- },
            },
          },
        },

        svelte = {
          -- needed otherwise changes in ts files are not picked up by svelte
          on_attach = function(client, bufnr)
            if client.name == 'svelte' then
              vim.api.nvim_create_autocmd('BufWritePost', {
                pattern = { '*.js', '*.ts' },
                group = vim.api.nvim_create_augroup('svelte_ondidchangetsorjsfile', { clear = true }),
                callback = function(ctx)
                  -- Here use ctx.match instead of ctx.file
                  client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
                end,
              })
            end

            -- attach keymaps if needed
          end,
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()
      vim.keymap.set('n', '<leader>mru', ':MasonInstall --force rust-analyzer@2025-07-14<CR>', { silent = true })
      vim.keymap.set('n', '<leader>mro', ':MasonInstall --force rust-analyzer@2024-03-11<CR>', { silent = true })

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            -- if server_name == 'tsserver' then
            --   server_name = 'ts_ls'
            -- end
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        --
        python = { 'isort', 'black' },
        json = { 'jq' },
        --
        xml = { 'xmllint' }, -- dont bother trying to use something from Mason ... install this debian package instead
        svg = { 'xmllint' }, -- dont bother trying to use something from Mason ... install this debian package instead

        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- TODO: actually configure to use prettier for javascript + typescript
        -- javascript = { { "prettierd", "prettier" } },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        html = { 'prettier' },
        sql = { 'pg_format' },
      },
      -- formatters = {
      --   ['sql-formatter'] = {
      --     command = 'sql-formatter',
      --     args = { '--stdin' }, -- read from stdin
      --     stdin = true,
      --   },
      -- },
    },
    init = function()
      vim.keymap.set('n', '<leader>cl', function()
        local formatters = require('conform').list_formatters()
        print('formatters:', vim.inspect(formatters))
      end, { desc = 'list formatters for current buffer' })
    end,
  },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {},
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      local types = require 'cmp.types'
      ---@type table<integer, integer>
      local modified_priority = {
        [types.lsp.CompletionItemKind.Variable] = types.lsp.CompletionItemKind.Method,
        [types.lsp.CompletionItemKind.Snippet] = 0, -- top
        [types.lsp.CompletionItemKind.Keyword] = 0, -- top
        [types.lsp.CompletionItemKind.Text] = 100, -- bottom
      }
      ---@param kind integer: kind of completion entry
      local function modified_kind(kind)
        return modified_priority[kind] or kind
      end

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          -- Show autocompletion after it disappears
          ['<C-k>'] = cmp.mapping.complete(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          ['<Tab>'] = cmp.mapping.confirm { select = true },
          -- ['<Right>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- -- unmap down,up and cr key, I still want to be able to move around text even if autocompletion is brought up
          -- ['<Down>'] = cmp.mapping(function(fallback)
          --   cmp.close()
          --   fallback()
          -- end, { 'i' }),
          -- ['<Up>'] = cmp.mapping(function(fallback)
          --   cmp.close()
          --   fallback()
          -- end, { 'i' }),
          -- a
          ['<CR>'] = cmp.mapping(function(fallback)
            cmp.close()
            fallback()
          end, { 'i' }),
          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          -- ['<right>'] = cmp.mapping(function()
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            -- ['<left>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/l3mon4d3/luasnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip' },
          { name = 'path' },
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            function(entry1, entry2) -- sort by length ignoring "=~"
              local len1 = string.len(string.gsub(entry1.completion_item.label, '[=~()_]', ''))
              local len2 = string.len(string.gsub(entry2.completion_item.label, '[=~()_]', ''))
              if len1 ~= len2 then
                return len1 - len2 < 0
              end
            end,
            cmp.config.compare.recently_used,
            function(entry1, entry2) -- sort by cmp.config.compare kind (Variable, Function etc)
              local kind1 = modified_kind(entry1:get_kind())
              local kind2 = modified_kind(entry2:get_kind())
              if kind1 ~= kind2 then
                return kind1 - kind2 < 0
              end
            end,
            function(entry1, entry2) -- score by lsp, if available
              local t1 = entry1.completion_item.sortText
              local t2 = entry2.completion_item.sortText
              if t1 ~= nil and t2 ~= nil and t1 ~= t2 then
                return t1 < t2
              end
            end,
            cmp.config.compare.score,
            cmp.config.compare.order,
          },
          -- comparators = {
          --   cmp.config.compare.recently_used,
          --   cmp.config.compare.score,
          --   cmp.config.compare.offset,
          --   cmp.config.compare.exact,
          --   -- cmp.config.compare.sort_text,
          --   cmp.config.compare.kind,
          -- },
        },
      }
    end,
  },
  -- Highlight todo, notes, etc in comments
  -- { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      do
        -- everything related to color theme goes here inside this block
        require('mini.colors').setup {}
        -- My own themes and autocommands around that
        require 'themes'
      end
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote

      require('mini.ai').setup { n_lines = 200 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      do
        local hipatterns = require 'mini.hipatterns'

        local keywords = {
          { key = 'FIX', group = 'MiniHipatternsFixme' },
          { key = 'FIXME', group = 'MiniHipatternsFixme' },
          { key = 'HACK', group = 'MiniHipatternsHack' },
          { key = 'WARN', group = 'MiniHipatternsHack' },
          { key = 'TODO', group = 'MiniHipatternsTodo' },
          { key = 'NOTE', group = 'MiniHipatternsNote' },
        }

        local highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
        }

        local bdrPattern = "[^a-zA-Z0-9'_()-]"

        for _, kw in pairs(keywords) do
          for _, key in pairs { kw.key, string.lower(kw.key) } do
            highlighters[key] = { pattern = bdrPattern .. '%f[%w]()' .. key .. '()%f[%W]' .. bdrPattern, group = kw.group }
            highlighters[key .. '_'] = { pattern = bdrPattern .. '%f[%w]()' .. key .. '()%f[%W]$', group = kw.group }
          end
        end

        hipatterns.setup { highlighters = highlighters }
      end

      -- -- Simple and easy statusline.
      -- --  You could remove this setup call if you don't like it,
      -- --  and try some other statusline plugin
      -- local statusline = require 'mini.statusline'
      -- -- set use_icons to true if you have a Nerd Font
      -- statusline.setup { use_icons = vim.g.have_nerd_font }
      do -- Simple and easy statusline.
        local statusline = require 'mini.statusline'

        -- set use_icons to true if you have a Nerd Font
        statusline.setup {
          use_icons = vim.g.have_nerd_font,
          content = {
            active = function()
              local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
              local git = MiniStatusline.section_git { trunc_width = 40 }
              local diff = MiniStatusline.section_diff { icon = 'Δ', trunc_width = 75 }
              local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
              local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
              local venv = (os.getenv 'VIRTUAL_ENV' or ''):match '([^/\\]+)$' or ''
              local wrap = vim.wo.wrap

              -- local filename = MiniStatusline.section_filename { trunc_width = 140 }
              local filename = vim.fn.expand '%f'
              local filenam_hl = 'MiniStatuslineFilename'
              do
                if #filename > 24 then
                  local ff = vim.fn.split(filename, '/')
                  if #ff > 3 then
                    filename = ff[1] .. '/.../' .. ff[#ff - 2] .. '/' .. ff[#ff - 1] .. '/' .. ff[#ff]
                  end
                end

                local unsaved = vim.api.nvim_get_option_value('modified', { buf = 0 })
                if unsaved then
                  filenam_hl = 'MiniStatuslineFilenameUnsaved'
                  filename = filename .. ' *'
                end
              end

              -- do we have any unsaved buffers?
              local bufs = vim.api.nvim_list_bufs()
              local workspace_hl = 'MiniStatuslineWorkspace'
              for _, buf in pairs(bufs) do
                local unsaved = vim.api.nvim_get_option_value('modified', { buf = buf })
                if unsaved then
                  workspace_hl = 'MiniStatuslineWorkspaceUnsaved'
                  break
                end
              end

              local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
              local location = MiniStatusline.section_location { trunc_width = 75 }
              local search = MiniStatusline.section_searchcount { trunc_width = 75 }

              -- get root_dir of the lsp client attached to this buffer
              local bufnr = vim.api.nvim_get_current_buf()
              local clients = vim.lsp.get_clients()
              local client = nil
              local root_dir = nil
              for _, c in pairs(clients) do
                if c.attached_buffers[bufnr] ~= nil then
                  client = c
                  root_dir = client.root_dir
                  break
                end
              end

              return MiniStatusline.combine_groups {
                { hl = mode_hl, strings = { mode } },
                { hl = 'MiniStatuslineBranch', strings = { git } },
                { hl = 'CurrentVenv', strings = { venv } },

                { hl = workspace_hl, strings = { vim.fs.basename(root_dir) } },
                { hl = 'MiniStatuslineChanges', strings = { diff } },
                { hl = 'MiniStatuslineDiagnostics', strings = { diagnostics, lsp } },
                '%<', -- Mark general truncate point
                { hl = filenam_hl, strings = { filename } },
                -- { hl = filenam_hl, strings = { vim.fn['zoom#statusline']() } },
                '%=', -- End left alignment
                { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                { hl = mode_hl, strings = { search, location, wrap and '↵' or '' } },
              }
            end,
          },
        }

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
          return '%2l:%-2v'
        end

        -- statusline.section_diff(args)
      end
    end,
  },
  -- {
  --   'nvim-treesitter/nvim-treesitter-textobjects',
  --   opts = {},
  -- }, -- This plugin does not seem to work.

  {
    'andymass/vim-matchup',
    -- TODO: I do not think this lazy = false is necessary
    lazy = false, -- or true with an event
    config = function()
      vim.g.matchup_matchparen_offscreen = {}
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'make',
        'terraform',
        'c',
        'dockerfile',
        'rust',
        'typescript',
        'tsx',
        'html',
        'lua',
        'markdown',
        'vim',
        'vimdoc',
        'javascript',
        'svelte',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      -- for 'andymass/vim-matchup' integration so that it can use treesitter
      matchup = {
        enable = true, -- mandatory, enables treesitter integration
        disable = { 'rust' },
        disable_virtual_text = true,
      },
      -- indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.bend = {
        install_info = {
          url = os.getenv 'HOME' .. '/.config/nvim/lua/custom/tree-sitter-bend', -- local path or git repo
          files = { 'src/parser.c' }, -- note that some parsers also require src/scanner.c or src/scanner.cc
          branch = 'main', -- default branch in case of git repo if different from master
        },
      }
      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
  {
    'isakbm/nvim-treesitter-context',
    branch = 'enhancement-nearest-parent',
    opts = {
      -- enable = false,
      multiline_threshold = 1,
      -- separator = '─',
      -- mode = 'topline',
    },
    init = function()
      -- vim.keymap.set('n', '[c', function()
      --   require('treesitter-context').go_to_context(vim.v.count1)
      -- end, { silent = true, desc = 'jump to line of parent scope in context' })

      vim.keymap.set('n', '[C', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true, desc = 'jump to line of parent scope in context' })

      vim.keymap.set('n', '[c', function()
        require('treesitter-context').go_to_parent(vim.v.count1)
      end, { silent = true, desc = 'jump to line of parent scope' })
    end,
  },
  {
    'michaelb/sniprun',
    build = 'bash ./install.sh',
    opts = {
      selected_interpreters = { 'Lua_nvim' },
      display = { 'Classic' },
    },
    init = function()
      require('sniprun').setup {
        display = { 'TempFloatingWindow' },
      }
      vim.keymap.set({ 'n', 'v' }, '<leader>r', ':SnipRun<CR>', { desc = 'run curr line with sniprun' })
      -- vim.keymap.set('v', '<leader>r', ":'<,'>SnipRun<CR>", { desc = 'run curr selection with sniprun' })
    end,
  },
  {
    'isakbm/gitgraph.nvim',
    opts = {
      symbols = {
        merge_commit = 'M',
        commit = '*',
      },
      format = {
        timestamp = '%H:%M:%S %d-%m-%Y',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
      },
      hooks = {
        on_select_commit = function(commit)
          print('selected commit:', commit.hash)
          vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
          vim.cmd(':DiffviewOpen ' .. commit.hash .. '^!')
        end,
        on_select_range_commit = function(from, to)
          print('selected range:', from.hash, to.hash)
          vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
          vim.cmd(':DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
        end,
      },
    },
    keys = {
      {
        '<leader>gl',
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        desc = 'GitGraph - Draw',
      },
      {
        '<leader>gtl',
        function()
          require('gitgraph').draw({}, { max_count = 5000 })
        end,
        desc = 'GitGraph - Draw',
      },
    },
  },
  {
    'chrisgrieser/nvim-various-textobjs',
    event = 'uienter',
    opts = { usedefaultkeymaps = true },
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    config = function()
      require('oil').setup {
        columns = {
          'icon',
          -- 'permissions',
          -- 'size',
          -- 'mtime',
        },
      }
      vim.keymap.set('n', '<leader>i', '<cmd>Oil .<CR>')
    end,
    -- keymaps = {
    --   ['<leader>\\'] = '<cmd>Oil<CR>',
    -- },
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
  {
    'gabrielpoca/replacer.nvim',
    opts = { rename_files = false },
    init = function()
      vim.keymap.set('n', '<leader>qe', ':lua require("replacer").run()<cr>', { silent = true, desc = '[Q]uickfix edit' })
    end,
  },
  {
    'jeetsukumaran/vim-indentwise',
    init = function()
      vim.keymap.set({ 'n', 'v' }, '<M-m>', '<Plug>(IndentWiseNextEqualIndentNoJList)')
      vim.keymap.set({ 'n', 'v' }, '<M-,>', '<Plug>(IndentWisePreviousEqualIndentNoJList)')
    end,
  },
  -- {
  --   'dhruvasagar/vim-zoom',
  --   init = function()
  --     -- vim.keymap.del('n', '<C-w>m')
  --     -- vim.keymap.set('n', '<Down><Up>', '<Plug>(zoom-toggle)', { silent = true })
  --   end,
  -- },
  {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup {
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
        -- Also override individual filetype configs, these take priority.
        -- Empty by default, useful if one of the "opts" global settings
        -- doesn't work well in a specific filetype
        per_filetype = {
          ['html'] = {
            enable_close = false,
          },
        },
      }
    end,
  },
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
    },
    lazy = false,
    branch = 'regexp', -- This is the regexp branch, use this for the new version
    config = function()
      require('venv-selector').setup()
    end,
    keys = {
      -- { ',v', '<cmd>VenvSelect<cr>' },
    },
  },
  {
    'hedyhli/outline.nvim',
    lazy = true,
    cmd = { 'Outline', 'OutlineOpen' },
    keys = { -- Example mapping to toggle outline
      { '<leader>o', '<cmd>Outline<CR>', desc = 'Toggle outline' },
    },
    opts = {
      -- Your setup opts here
      outline_window = {
        position = 'left',
        auto_jump = true,
      },
      keymaps = {
        goto_location = 'o',
        peek_location = '<cr>',
      },
    },
  },
  'brianhuster/unnest.nvim',
  require 'kickstart.plugins.indent_line',
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
