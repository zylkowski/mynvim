-- MY FUCKING INIT ~Arek

-- TODO:
-- - rust-analyzer only works when in .rs file. I'd like it to work already when in folder with Cargo.toml
-- -

-- NOTE: :help localleader
vim.g.mapleader = ' ' -- Set <space> as the leader key
vim.g.maplocalleader = ' ' --- Set <space> as the local leader key
vim.g.have_nerd_font = true -- Set to true if you have a Nerd Font installed

-- NOTE::help option-list
--
-- Sync clipboard between OS and Neovim.
-- Remove this option if you want your OS clipboard to remain independent.
vim.opt.clipboard = 'unnamedplus' --  See `:help 'clipboard'`
-- vim.opt.updatetime = 80 -- update time
-- vim.opt.timeoutlen = 80 -- Decrease mapped sequence wait time : Displays which-key popup sooner
-- if you don't use whichkey then use times below
vim.opt.updatetime = 250 -- update time

vim.opt.timeoutlen = 1000 -- Decrease mapped sequence wait time : Displays which-key popup sooner
vim.cmd 'autocmd InsertLeave * set timeoutlen=1000'
vim.cmd 'autocmd InsertEnter * set timeoutlen=0'

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true -- yes use tempr gui colors
vim.opt.wrap = false -- don't wrap lines
vim.opt.fillchars:append { diff = '/' } -- fillchars for diffview?
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
  -- virtual_text = {
  --   virt_text_pos = 'right_align', -- Make error highlights right aligned
  --   underline = {
  --     severity = vim.diagnostic.severity.WARN,
  --   },
  --   format = function()
  --     return ''
  --   end,
  --   -- signs = { text = { [vim.diagnostic.severity.ERROR] = '❌', [vim.diagnostic.severity.WARN] = '⚠: ' } },
  -- },
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

vim.api.nvim_create_user_command('Arr', function(opts)
  local x = tonumber(opts.args:match '^(%d+)')
  local y = tonumber(opts.args:match '%s+(%d+)$')

  if not x or not y then
    vim.api.nvim_err_writeln 'Invalid arguments. Usage: :Arr x y (e.g., :Arr 2 3)'
    return
  end

  -- Generate the 2D array as a string
  local array = ' [\n'
  for i = 1, y do
    array = array .. '    [' .. string.rep('_,', x - 1) .. '_],\n'
  end
  array = array .. ' ]'

  -- Insert the array at the cursor position
  vim.api.nvim_put(vim.split(array, '\n'), 'c', true, true)
end, { nargs = 1 })

--========================= KEYMAPS =======================

--========================= ESC BINDINGS ==================
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>', { silent = true })
vim.keymap.set('i', '<Esc>]', '<Space>', { noremap = true, silent = true })

-- returns true if buffer is trivial
--- @param buf integer -- 0 is current buffer
--- @return boolean
local function buf_is_trivial(buf)
  local n = vim.api.nvim_buf_line_count(buf)
  if n == 0 then
    return true
  end
  if n == 1 then
    local c = #vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
    if c == 0 then
      return true
    end
  end
  return false
end

local function get_last_command()
  local result = vim.fn.system 'tail -n 1 ~/.bash_history'
  result = result:match '^%s*(.-)%s*$'
  return result
end

local function rename_terminal_to_last_command()
  vim.schedule(function()
    vim.wait(200) -- need this otherwise vim is too faaaaaaaaaaaaaast
    local last_cmd = get_last_command()
    local buf_number = vim.api.nvim_get_current_buf()
    if last_cmd then
      vim.cmd('file term://' .. buf_number .. '//' .. last_cmd)
    end
  end)
end
vim.api.nvim_create_user_command('RenameTerminal', rename_terminal_to_last_command, {})
vim.keymap.set('t', '<Enter>', '<Enter><C-\\><C-n>:RenameTerminal<Enter>a', { silent = true })

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
vim.keymap.set('n', '<C-w>-', function()
  vim.cmd(math.floor(vim.fn.winheight(0) * 0.35) .. 'split')
  vim.cmd 'terminal'
end, { desc = 'Horizontal split' })
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

vim.keymap.set('n', '<leader>qp', function()
  vim.fn.setqflist({
    {
      filename = vim.fn.expand '%',
      lnum = vim.fn.line '.',
      col = vim.fn.col '.',
      text = vim.fn.getline '.',
    },
  }, 'a')
  -- vim.cmd 'botright copen | wincmd p'
end, { desc = '[Q]uickfix [P]ut' })
vim.keymap.set('n', '<leader>qd', function()
  local qflist = vim.fn.getqflist()
  local idx = vim.fn.getqflist({ idx = 0 }).idx

  if idx > 0 and idx <= #qflist then
    table.remove(qflist, idx)
    vim.fn.setqflist(qflist, 'r')
    vim.notify('Removed entry at index ' .. idx, vim.log.levels.INFO)
  else
    vim.notify('Invalid quickfix entry', vim.log.levels.ERROR)
  end
end, { desc = '[Q]uickfix [D]elete entry' })

vim.keymap.set('n', '<leader>qr', ':cexpr []<cr>', { desc = '[Q]uickfix [R]remove list' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

-- vim.keymap.set('n', '<leader>qq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>qo', ':cwindow<cr>', { desc = 'Open [Q]uickfix list' })
-- vim.keymap.set('n', '<leader>qo', ':vertical cwindow<cr>:vertical resize 90<cr>', { desc = 'Open [Q]uickfix list' })
vim.keymap.set('n', ']q', ':cn<cr>', { desc = 'Go to next [Q]uickfix list' })
vim.keymap.set('n', '[q', ':cp<cr>', { desc = 'Go to next [Q]uickfix list' })
vim.keymap.set('n', '<leader>qc', function()
  vim.cmd 'ccl'
  -- vim.fn.setqflist({}, 'r')
end, { desc = '[Q]uickfix [C]lose' })

-- NOTE: swap lines like in vscode
--
--   we've bound <M-*> so the `Alt` or `Modifier` key, however, see :h :map-alt and you'll notice that
--   nvim is not able to distinguish between `Esc` and `Alt` if key press is fast enough, we'll just live
--   with this, it rarely causes issues, but if you press `Esc` + j  or `Esc + k` very quickly while
--   in normal mode, you'll also trigger the below keymaps.
vim.keymap.set('n', '<C-k>', ':m-2<cr>', { desc = 'swap line with line above' }) -- vscode <alt> + <down>
vim.keymap.set('n', '<C-j>', ':m+1<cr>', { desc = 'swap line with line below' }) -- vscode <alt> + <up>

-- -- NOTE: Jump between tabs using 'Alt + number'
-- for i = 1, 9 do
--   vim.keymap.set('n', '<M-' .. i .. '>', i .. 'gt', { desc = '[T]ab ' .. i })
-- end
--
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

-- Add this to your .bashrc in order to make the following autocommand to work. It enables OSC7 signaling
-- function print_osc7() {
--   printf "\033]7;file://$HOSTNAME/$PWD\033\\"
-- }
-- # PROMPT_COMMAND='$(print_osc7)${PROMPT_COMMAND:+;$PROMPT_COMMAND}'
vim.api.nvim_create_autocmd({ 'TermRequest' }, {
  callback = function(e)
    -- vim.print(vim.v.termrequest)
    if string.sub(vim.v.termrequest, 1, 4) == '\x1b]7;' then
      local dir = string.gsub(vim.v.termrequest, '\x1b]7;file://[^/]*', '')
      if vim.fn.isdirectory(dir) == 0 then
        return
      end
      vim.api.nvim_buf_set_var(e.buf, 'last_osc7_payload', dir)
      if vim.api.nvim_get_current_buf() == e.buf then
        vim.cmd.cd(dir)
      end
    end
  end,
})
vim.api.nvim_create_autocmd({ 'bufenter', 'winenter', 'dirchanged' }, {
  callback = function(e)
    if vim.b.last_osc7_payload ~= nil and vim.fn.isdirectory(vim.b.last_osc7_payload) == 1 then
      vim.cmd.cd(vim.b.last_osc7_payload)
    end
  end,
})

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

local hlgs = {}

local my_ns = vim.api.nvim_create_namespace 'arek_hl'
--- works by searching for string of the form "#rrggbb"
--- keeps a list of created highlght groups and reuses
--- them, ... only searches in the current visible part
--- of the buffer, and only upates on changes
local function hex_color_highlight()
  local top = vim.fn.line 'w0'
  local bot = vim.fn.line 'w$'

  --- @type table<string, string>
  ---
  ---
  -- local hlgs = vim.g.hex_highlight_groups
  if not hlgs then
    hlgs = {}
  end

  local text = vim.api.nvim_buf_get_lines(0, top, bot, true)

  vim.api.nvim_buf_clear_namespace(0, my_ns, 0, -1)
  vim.api.nvim_win_set_hl_ns(0, my_ns)

  for idx, line in pairs(text) do
    local offset = 1
    for m in line:gmatch '["\']#%x%x%x%x%x%x["\']' do
      local loc = line:find(m, offset, true)
      offset = loc + 9
      local row = idx + top
      local col_start = loc
      local col_end = offset

      local hlg = false
      local sm = m:sub(3, 8)
      for _, c_hlg in pairs(hlgs) do
        if c_hlg == sm then
          hlg = true
          break
        end
      end

      if not hlg then
        vim.api.nvim_set_hl(my_ns, sm, { fg = '#' .. sm })
        hlgs[#hlgs + 1] = sm
      end

      if col_start and col_end then
        vim.api.nvim_buf_add_highlight(0, my_ns, sm, row - 1, col_start - 1, col_end - 1)
      end
    end
  end
end

-- todo: should add textchanged
-- "#aaaaaa" "#ffaabb"
vim.api.nvim_create_autocmd({ 'winenter', 'winscrolled' }, {
  callback = function()
    hex_color_highlight()
  end,
})

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

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- { -- Useful plugin to show you pending keybinds.
  --   'folke/which-key.nvim',
  --   event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  --   config = function() -- This is the function that runs, AFTER loading
  --     require('which-key').setup {
  --
  --       win = {
  --         border = 'rounded', -- none, single, double, shadow
  --       },
  --     }
  --
  --     -- Document existing key chains
  --     require('which-key').add {
  --
  --       { '<leader>c', group = '[C]ode' },
  --       { '<leader>c_', hidden = true },
  --       { '<leader>d', group = '[D]ocument' },
  --       { '<leader>d_', hidden = true },
  --       { '<leader>g', group = '[G]it' },
  --       { '<leader>g_', hidden = true },
  --       { '<leader>h', group = 'Git [H]unk' },
  --       { '<leader>h_', hidden = true },
  --       { '<leader>r', group = '[R]ename' },
  --       { '<leader>r_', hidden = true },
  --       { '<leader>s', group = '[S]earch' },
  --       { '<leader>s_', hidden = true },
  --       { '<leader>t', group = '[T]oggle' },
  --       { '<leader>t_', hidden = true },
  --       { '<leader>w', group = '[W]orkspace' },
  --       { '<leader>w_', hidden = true },
  --       { '<leader>q', group = '[Q]uickfix' },
  --       { '<leader>q_', hidden = true },
  --       -- ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  --       -- ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  --       -- ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  --       -- ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  --       -- ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
  --       -- ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  --       -- ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  --       -- ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  --     }
  --     -- visual mode
  --     require('which-key').add({
  --       { '<leader>h', desc = 'Git [H]unk', mode = 'v' },
  --       { '<leader>s', desc = '[S]ubstitute', mode = 'v' },
  --       -- ['<leader>h'] = { 'Git [H]unk' },
  --       -- ['<leader>s'] = { '[S]ubstitute' },
  --     }, { mode = 'v' })
  --   end,
  -- },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
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
              ['<c-enter>'] = 'to_fuzzy_refine',
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

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
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
      vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame<CR>', { desc = '[G]it [B]lame toggle' })
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
            if buf_is_trivial(buf) then
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

            if buf_is_trivial(0) then
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
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
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
                experimental = {
                  enable = true,
                },
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
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
              runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
              },
              -- Make the server aware of Neovim runtime files
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                },
              },
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
      vim.keymap.set('n', '<leader>mru', ':MasonInstall --force rust-analyzer<CR>', { silent = true })
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
            if server_name == 'tsserver' then
              server_name = 'ts_ls'
            end
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
      },
    },
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
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
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
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      do
        -- everything related to color theme goes here inside this block
        require('mini.colors').setup {}
        --
        -- ---@type Colorscheme
        -- local theme = MiniColors.get_colorscheme 'retrobox'

        ---@type table<string, string>
        local dune = {
          background = '#181818',
          base = '#845A40',
          base_toned = '#a8714d',
          highlighted = '#efcfa0',
          normal = '#b8a586',
          disabled = '#847762',
          attention1 = '#83A598',
          attention2 = '#6d86b2',
          important = '#bf6079',
          important_highlighted = '#df8099',
          important_darker = '#E7545E',
          place = '#8EC07C',
          pear2 = '#637f59',

          attention3 = '#a8bda0',
          attention4 = '#95ad8c',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }

        local aqua_rusty = {
          background = '#181818',
          base = '#6B7D7D',
          base_toned = '#8eaf9d',
          highlighted = '#A6D8D4',
          normal = '#b8a586',
          disabled = '#847762',
          attention1 = '#F7b34B',
          attention2 = '#f0b36f',
          important = '#f17c74',
          important_highlighted = '#fb6c64',
          important_darker = '#E7545E',
          place = '#8EC07C',
          pear2 = '#637f59',

          attention3 = '#a8bda0',
          attention4 = '#95ad8c',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }

        local hulk = {
          background = '#011628',
          base = '#4d699e',
          base_toned = '#3d79ae',
          highlighted = '#b6c8b4',
          normal = '#b8a5a6',
          disabled = '#847772',
          attention1 = '#a065b2',
          attention2 = '#d499b9',
          important = '#f17c74',
          important_highlighted = '#fb6c64',
          important_darker = '#E7545E',
          place = '#8EC07C',
          pear2 = '#637f59',

          attention3 = '#e8c1c5',
          attention4 = '#ffb1d4',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }

        local ebony = {
          background = '#181818',
          base = '#657256',
          base_toned = '#d3b88c',
          highlighted = '#b6c8b4',
          normal = '#b8a586',
          disabled = '#847772',
          attention1 = '#F7b35B',
          attention2 = '#d499b9',
          important = '#f17c74',
          important_highlighted = '#fb6c64',
          important_darker = '#E7545E',
          place = '#8EC07C',
          pear2 = '#637f59',

          attention3 = '#d3426e',
          attention4 = '#e63946',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }

        local dunelike = {
          background = '#181818',
          base = '#657256',
          base_toned = '#d3b88c',
          highlighted = '#b6c8a4',
          normal = '#b8a586',
          disabled = '#847772',
          attention1 = '#ffcfa0',
          attention2 = '#d499b9',
          important = '#f17c74',
          important_highlighted = '#fb6c64',
          important_darker = '#E7545E',
          place = '#8EC07C',
          pear2 = '#637f59',

          attention3 = '#E7545E',
          attention4 = '#e63946',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }

        local mogilska = {
          background = '#181818',
          base = '#a64236',
          base_toned = '#c65246',
          highlighted = '#f3b88a',
          normal = '#b8a586',
          disabled = '#847772',
          attention1 = '#8EC07C',
          attention2 = '#7e8f60',
          important = '#f17c74',
          important_highlighted = '#fb6c64',
          important_darker = '#E7545E',
          place = '#d499b9',
          pear2 = '#a46999',

          attention3 = '#E7545E',
          attention4 = '#e63946',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }

        local puple = {
          background = '#181825',
          base = '#8468a9',
          base_toned = '#a46999',
          highlighted = '#f3b88a',
          normal = '#b8a586',
          disabled = '#847772',
          attention1 = '#8EC07C',
          attention2 = '#7e8f60',
          important = '#f17c74',
          important_highlighted = '#fb6c64',
          important_darker = '#E7545E',
          place = '#d499b9',
          pear2 = '#a46999',

          attention3 = '#E7545E',
          attention4 = '#e63946',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }
        local puple_insert = {
          -- background = '#FAFAFA',
          background = '#1f1f1f',
          base = '#846889',
          base_toned = '#845979',
          highlighted = '#e3a66a',
          normal = '#b8a586',
          disabled = '#847772',
          attention1 = '#8EC07C',
          attention2 = '#7e8f60',
          important = '#f17c74',
          important_highlighted = '#fb6c64',
          important_darker = '#E7545E',
          place = '#d499b9',
          pear2 = '#a46999',

          attention3 = '#E7545E',
          attention4 = '#e63946',
          gray = '#404040',
          mid_gray = '#4a4a4a',
          light_gray = '#505050',
          dark_gray = '#253535',
          black = '#101010',
        }

        local c = puple

        local function set_theme(c, theme)
          ---@type table<string, vim.api.keyset.highlight>
          local hl = theme.groups

          -- sets several highlight, if any already existed it gets overwritten entirely
          ---@param names string | table<string>
          ---@param data vim.api.keyset.highlight
          local function set_hl(names, data)
            if type(names) == 'string' then
              set_hl({ names }, data)
              return
            end
            for _, name in pairs(names) do
              hl[name] = data
            end
          end

          -- tweaks an existing highlight, only adds or merges does not overwrite
          ---@param names string | table<string>
          ---@param data vim.api.keyset.highlight
          local function tweak_hl(names, data)
            if type(names) == 'string' then
              tweak_hl({ names }, data)
              return
            end
            for _, name in pairs(names) do
              hl[name] = hl[name] or {}
              hl[name] = vim.tbl_extend('force', hl[name], data)
            end
          end
          tweak_hl('Search', { fg = c.attention1 })
          set_hl('Visual', { bg = c.dark_gray })
          tweak_hl('IncSearch', { fg = c.highlighted })
          tweak_hl('DiagnosticUnderlineError', { undercurl = true })
          set_hl('DiagnosticUnnecessary', { fg = c.disabled })

          set_hl('NormalFloat', { bg = nil })

          set_hl('Normal', { fg = c.normal, bg = c.background })

          set_hl('SignColumn', hl.Normal)

          set_hl({
            'directory',
            'statement',
            'function',
            '@tag',
            '@function.builtin',
            '@tag.builtin',
            '@lsp.type.formatspecifier',
          }, { fg = c.attention1 })

          set_hl({
            'delimiter',
            'keyword',
            'repeat',
            'conditional',
            'operator',
            '@keyword.type',
            'winseparator',
            '@tag.delimiter',
            '@constructor.lua',
            'GitGraphHash',
          }, { fg = c.base })

          set_hl({
            'Type',
            'Number',
            'Float',
            'Boolean',
            'String',
            'Structure',
            'Constant',
            'GitSignsChange',
            'CursorLineNr',
            '@constructor',
            '@type.builtin',
            'GitGraphTimestamp',
          }, { fg = c.highlighted })

          set_hl({
            'Typedef',
          }, { fg = c.attention3 })

          set_hl({
            'Identifier',
            '@markup.raw',
            '@tag.attribute',
            'markdownBlockQuote',
            'GitGraphBranchMsg',
          }, { fg = c.normal })

          set_hl({
            'Include',
            'Label',
            'Title',
            'GitSignsAdd',
            'LeapLabelPrimary',
            '@lsp.type.namespace',
            '@module',
            'GitGraphAuthor',
          }, { fg = c.place })

          set_hl({
            'LeapLabelPrimary',
          }, { fg = c.black, bg = c.normal })

          -- TODO: example todo
          -- NOTE: example note
          -- FIXME: example fixme
          set_hl({
            'TodoBgTODO',
            'TodoBgNOTE',
          }, { fg = c.gray, bg = c.place })

          set_hl({
            'TodoFgFIX',
          }, { fg = c.important_darker })

          set_hl({
            'SpecialChar',
            'GitSignsDelete',
            '@constant.builtin',
            '@lsp.type.lifetime',
            '@lsp.typemod.keyword.async',
            'Macro',
          }, { fg = c.important })

          set_hl({
            'Comment',
            'LeapBackdrop',
          }, { fg = c.light_gray })

          set_hl({
            'TodoBgFIX',
            'TodoBgFIXME',
          }, { fg = c.gray, bg = c.important_darker })

          set_hl('Special', { fg = c.base_toned })

          set_hl('flogBranch0', { fg = '#458588' })
          set_hl('flogBranch1', { fg = '#458588' })
          set_hl('flogBranch2', { fg = '#689d6a' })
          set_hl('flogBranch3', { fg = '#b16286' })
          set_hl('flogBranch4', { fg = '#d79921' })
          set_hl('flogBranch5', { fg = '#98971a' })
          set_hl('flogBranch6', { fg = '#E7545E' })
          set_hl('flogBranch7', { fg = '#ad6639' })
          set_hl('flogBranch8', { fg = '#b53a35' })
          set_hl('flogBranch9', { fg = '#d5651c' })

          set_hl({
            'DiffAdd',
            'DiffChange',
          }, { bg = '#003530' })

          set_hl('DiffText', { bg = '#004040' })
          set_hl('DiffDelete', { fg = '#F00000' })
          set_hl('DiffviewDiffDeleteDim', { fg = '#F00000' })

          set_hl({
            'MiniStatuslineBranch',
            'MiniStatuslineWorkspace',
            'MiniStatuslineWorkspaceUnsaved',
            'MiniStatuslineChanges',
            'MiniStatuslineDiagnostics',
            'MiniStatuslineFileinfo',
          }, { bg = '#333333' })

          tweak_hl('MiniStatuslineBranch', { fg = c.place })
          tweak_hl('MiniStatuslineWorkspaceUnsaved', { fg = c.important_darker })
          tweak_hl('MiniStatuslineChanges', { fg = c.highlighted })
          tweak_hl('MiniStatuslineDiagnostics', { fg = c.attention1 })
          tweak_hl('MiniStatuslineFileinfo', { fg = c.attention1 })

          set_hl({
            'MiniStatuslineModeNormal',
            'MiniStatuslineModeVisual',
            'MiniStatuslineModeInsert',
          }, { fg = '#333333' })

          tweak_hl('MiniStatuslineModeNormal', { bg = c.highlighted })
          tweak_hl('MiniStatuslineModeVisual', { bg = c.important })
          tweak_hl('MiniStatuslineModeInsert', { bg = c.attention1 })

          ---@diagnostic disable-next-line: undefined-field
          theme:apply()
        end

        -- vim.api.nvim_create_autocmd('CmdlineEnter', {
        --   desc = 'Background change on entering insert mode',
        --   group = vim.api.nvim_create_augroup('arek-escape-insert', { clear = false }),
        --   callback = function()
        --     if buf_is_trivial(0) then
        --       return
        --     end
        --     -- set_hl('Normal', { fg = c.white, bg = '#303235' })
        --     set_theme(puple_term, MiniColors.get_colorscheme())
        --   end,
        -- })
        -- vim.api.nvim_create_autocmd('CmdlineLeave', {
        --   desc = 'Background change when leaving insert mode',
        --   group = vim.api.nvim_create_augroup('arek-escape-insert', { clear = false }),
        --   callback = function()
        --     -- set_hl('Normal', { fg = c.white, bg = c.background })
        --     set_theme(puple, MiniColors.get_colorscheme())
        --   end,
        -- })
        vim.api.nvim_create_autocmd({ 'InsertEnter', 'TermEnter' }, {
          desc = 'Background change on entering insert mode',
          group = vim.api.nvim_create_augroup('arek-escape-insert', { clear = false }),
          callback = function()
            if buf_is_trivial(0) then
              return
            end
            -- set_hl('Normal', { fg = c.white, bg = '#303235' })
            set_theme(puple_insert, MiniColors.get_colorscheme())
          end,
        })
        vim.api.nvim_create_autocmd({ 'InsertLeave', 'TermLeave' }, {
          desc = 'Background change when leaving insert mode',
          group = vim.api.nvim_create_augroup('arek-escape-insert', { clear = false }),
          callback = function()
            -- set_hl('Normal', { fg = c.white, bg = c.background })
            set_theme(puple, MiniColors.get_colorscheme())
          end,
        })

        set_theme(puple, MiniColors.get_colorscheme 'retrobox')
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
                { hl = filenam_hl, strings = { vim.fn['zoom#statusline']() } },
                '%=', -- End left alignment
                { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                { hl = mode_hl, strings = { search, location } },
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
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
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
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      -- enable = false,
      multiline_threshold = 1,
      separator = '─',
      -- mode = 'topline',
    },
    init = function()
      vim.keymap.set('n', '[c', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true, desc = 'jump to line of parent context' })
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
      vim.keymap.set('n', '<leader>o', '<cmd>Oil .<CR>')
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
      vim.keymap.set('n', '<leader>h', ':lua require("replacer").run()<cr>', { silent = true })
    end,
  },
  {
    'jeetsukumaran/vim-indentwise',
    init = function()
      vim.keymap.set({ 'n', 'v' }, '<M-m>', '<Plug>(IndentWiseNextEqualIndentNoJList)')
      vim.keymap.set({ 'n', 'v' }, '<M-,>', '<Plug>(IndentWisePreviousEqualIndentNoJList)')
    end,
  },
  {
    'dhruvasagar/vim-zoom',
    init = function()
      -- vim.keymap.del('n', '<C-w>m')
      vim.keymap.set('n', '<Down><Up>', '<Plug>(zoom-toggle)', { silent = true })
    end,
  },
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
