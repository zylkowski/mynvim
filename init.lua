-- MY FUCKING INIT ~Arek

-- NOTE: :help localleader
vim.g.mapleader = ' ' -- Set <space> as the leader key
vim.g.maplocalleader = ' ' --- Set <space> as the local leader key
vim.g.have_nerd_font = true -- Set to true if you have a Nerd Font installed

-- NOTE::help option-list
--
-- Sync clipboard between OS and Neovim.
-- Remove this option if you want your OS clipboard to remain independent.
vim.opt.clipboard = 'unnamedplus' --  See `:help 'clipboard'`
vim.opt.updatetime = 120 -- Decrease update time
vim.opt.timeoutlen = 300 -- Decrease mapped sequence wait time : Displays which-key popup sooner
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

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.diagnostic.config {
  virtual_text = {
    virt_text_pos = 'right_align', -- Make error highlights right aligned
    underline = {
      severity = vim.diagnostic.severity.WARN,
    },
    format = function()
      return ''
    end,
    signs = { text = { [vim.diagnostic.severity.ERROR] = '❌', [vim.diagnostic.severity.WARN] = '⚠: ' } },
  },
  float = { scope = 'l' },
  severity_sort = true,
}

--========================= KEYMAPS =======================
--
-- Those Keymaps should be independent of Plugins
--
--

--========================= ESC BINDINGS ==================
--=========================================================
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<Esc><Esc>', function()
  local ntabs = #vim.api.nvim_list_tabpages()
  if ntabs <= 1 then
    return
  end

  -- NOTE: we avoid closing tab if current window is relative
  local not_relative = vim.api.nvim_win_get_config(0).relative == ''
  if not_relative then
    vim.cmd [[:tabc]]
  end
end, {
  desc = 'Close current tab',
})

-- takes buffer number and removes the ESC ESC local keybinding
--- @param buf integer
local function cancel_esc_esc_once_buf(buf)
  pcall(vim.keymap.del, 'n', '<Esc><Esc>', { buffer = buf })
end

-- any parent tab page, useful for handy closeing of plugins that
-- spawn their own tabpages
--- @param buf integer
local function esc_esc_once_buf(buf)
  vim.keymap.set('n', '<Esc><Esc>', function()
    vim.cmd ':tabc'
    cancel_esc_esc_once_buf(buf)
  end, { buffer = buf })
  -- NOTE: we also need to register an autocommand that will clear the above keymap
  --       if the buffer is leaving the window it was in
  --       :
end

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

--========================= ESC BINDINGS ==================
--=========================================================

vim.keymap.set('v', '<leader>sc', '"hy:%s/<C-r>h//gc<left><left><left>', { desc = '[S]ubstitute [C]hange' })
vim.keymap.set('v', '<leader>sa', '"hy:%s/<C-r>h/<C-r>h/gc<left><left><left>', { desc = '[S]ubstitute [A]ppend' })

vim.keymap.set('n', 'yp', 'yy<cr>kp<cr>k', { desc = '[Y]ank [P]aste - Duplicate Line' })

-- vim.keymap.set('n', 'p', 'p<leader>f') -- autoformat after paste/put -- Does not work ;_;
vim.keymap.set('n', '<C-w>n', ':tabnew<cr>', { desc = '[N]ew window' })

vim.keymap.set({ 'v', 'n' }, '<M-h>', ':tabprevious<cr>')
vim.keymap.set({ 'v', 'n' }, '<M-l>', ':tabNext<cr>')

-- vim.keymap.set('n', '<M-j>', '12j')
-- vim.keymap.set('n', '<M-k>', '12k')
do
  local dt = 10
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

-- NOTE: nice way to escape lots of plugins like diffview and flog
-- vim.keymap.set('n', '<Esc><Esc>', ':tabc<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

vim.keymap.set('n', '<leader>qq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', ']q', ':cn<cr>', { desc = 'Go to next [Q]uickfix list' })
vim.keymap.set('n', '[q', ':cp<cr>', { desc = 'Go to next [Q]uickfix list' })
vim.keymap.set('n', '<leader>qc', ':ccl<cr>', { desc = '[Q]uickfix [C]lose' })
vim.keymap.set('n', '<leader>qf', function()
  local curr_qf_list = vim.fn.getqflist()

  -- try reading :help getqflist-examples
  local items = vim.fn.getqflist { id = 0, items = 0 }
  print(vim.inspect(items))
  -- for i in items do
  --   print(i)
  -- end
  -- for i = 0, len(curr_qf_list) do
  --   print(curr_qf_list[i].user_data)
  -- end
end)

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- NOTE: swap lines like in vscode
--
--   we've bound <M-*> so the `Alt` or `Modifier` key, however, see :h :map-alt and you'll notice that
--   nvim is not able to distinguish between `Esc` and `Alt` if key press is fast enough, we'll just live
--   with this, it rarely causes issues, but if you press `Esc` + j  or `Esc + k` very quickly while
--   in normal mode, you'll also trigger the below keymaps.
vim.keymap.set('n', '<C-k>', ':m-2<cr>', { desc = 'swap line with line above' }) -- vscode <alt> + <down>
vim.keymap.set('n', '<C-j>', ':m+1<cr>', { desc = 'swap line with line below' }) -- vscode <alt> + <up>

-- NOTE: Jump between tabs using 'Alt + number'
for i = 1, 9 do
  vim.keymap.set('n', '<M-' .. i .. '>', i .. 'gt', { desc = '[T]ab ' .. i })
end

-- useful for figuring out what higlight groups are relevant for stuff under cursor
vim.keymap.set('n', '<leader>I', function()
  vim.show_pos()
end)

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

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

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

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
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

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
        ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
      }
      -- visual mode
      require('which-key').register({
        ['<leader>h'] = { 'Git [H]unk' },
        ['<leader>s'] = { '[S]ubstitute' },
      }, { mode = 'v' })
    end,
  },

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
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          mappings = {
            i = { ['<c-enter>'] = 'to_fuzzy_refine' },
            i = { ['<Esc><Esc>'] = require('telescope.actions').close },
            n = { ['<Esc><Esc>'] = require('telescope.actions').close },
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
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- TODO: CONSIDER neogit ....
  -- NOTE: Git plugins ...
  {
    'rbong/vim-flog',
    dependencies = {
      'tpope/vim-fugitive',
      'sindrets/diffview.nvim',
    },
    config = function()
      -- vim.keymap.set('n', '<leader>gl', ':Flog -all -date=relative<cr>', { desc = '[G]it [L]og' })
      vim.keymap.set('n', '<leader>gl', function()
        -- whenever we enter a flog buffer we want to register
        -- this autocommand ONCE, it in turn registers the esc esc
        -- key binding on the buffer in it such that it's easy to
        -- leave flog
        vim.api.nvim_create_autocmd({ 'BufEnter' }, {
          callback = function(ctx)
            -- this helps us catch any bugs, if we see this in the fidget history
            -- then we know that we did not deregister the autocommand correctly, the use of once should make this automatic
            require('fidget').notify('flog - buf enter', '@comment.error', { annote = 'FLOG' })
            esc_esc_once_buf(ctx.buf)
          end,
          once = true,
        })
        vim.cmd [[:Flog -all -max-count=999999 -date=relative]]
        vim.schedule(function()
          vim.fn.search 'HEAD ->'
        end)
        vim.api.nvim_feedkeys('zz', 'n', false)
      end, { desc = '[G]it [L]og' })
      -- vim.keymap.set('n', '<leader>gl', ':Flog -format=%ar%x20[%h]%x20%d%x20%an <cr>', { desc = '[G]it [L]og' })
      vim.keymap.set('n', '<leader>gs', ':Git<cr>', { desc = '[G]it [S]tatus' })

      -- Returns the selected commit by fugitive, the one selected by hitting enter
      -- ... we are able to do this by finding the loaded buffer for fugitive
      -- that flog uses, and extract its commit hash
      --- @return string
      local function flogSelectedCommit()
        local buffers = vim.api.nvim_list_bufs()
        for _, buffer in ipairs(buffers) do
          local name = vim.api.nvim_buf_get_name(buffer)
          local loaded = vim.api.nvim_buf_is_loaded(buffer)
          if loaded and name then
            local isFugitive = string.match(name, 'fugitive:.*git//%x*')
            if isFugitive then
              local h = string.match(name, '%x*$')
              if h then
                return string.sub(h, 1, 7)
              end
            end
          end
        end
        return ''
      end

      -- get the commit under the cursor
      --- @return boolean, string asdfasdf
      local function flogCommitUnderCursor()
        return pcall(vim.fn['flog#Format'], '%H')
      end

      -- NOTE: opens up diffview relative to commit under cursor
      vim.keymap.set('n', ',', function()
        local ok, commit = flogCommitUnderCursor()
        if ok then
          return ':DiffviewOpen ' .. commit .. '<cr>'
        end
      end, { expr = true, desc = 'display changes of HEAD relative to commit under cursor' })

      -- NOTE: opens up diffview for change introduced by commit under cursor
      vim.keymap.set('n', ';', function()
        local ok, commit = flogCommitUnderCursor()
        if ok then
          return ':DiffviewOpen ' .. commit .. '^!<cr>'
        end
      end, { expr = true, desc = 'display changes introduced by commit under cursor' })

      vim.keymap.set('n', '-', function()
        local ok, cc = flogCommitUnderCursor()
        if ok then
          local h = flogSelectedCommit()
          if h == '' then
            return
          end
          return ':DiffviewOpen ' .. cc .. '..' .. h .. '<cr>'
        end
      end, { expr = true })
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

      -- blame
      vim.keymap.set('n', '<leader>gb', ':Gitsigns toggle_current_line_blame<CR>', { desc = '[G]it [B]lame toggle' })

      -- diff this
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
        view_leave = function()
          local buf = vim.api.nvim_get_current_buf()
          -- print('leaving view: buf =', buf)
          cancel_esc_esc_once_buf(buf)
        end,
        view_enter = function()
          local buf = vim.api.nvim_get_current_buf()
          -- print('entering view: buf =', buf)
          esc_esc_once_buf(buf)
        end,
        diff_buf_read = function(buf)
          -- print('diffview read buf: ', buf)
          vim.opt_local.cursorline = false
          esc_esc_once_buf(buf)
        end,
        view_opened = function()
          -- print 'opening view'
          vim.fn.timer_start(100, function()
            local tp = vim.api.nvim_get_current_tabpage()
            local wins = vim.api.nvim_tabpage_list_wins(tp)
            local win = wins[3]

            local buf = vim.api.nvim_win_get_buf(wins[3])
            if buf_is_trivial(buf) then
              print 'no change'
              vim.cmd [[:DiffviewClose]]
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
      vim.keymap.set(
        'n',
        '<leader>gd',
        --[[
             1. open diffview
             2. turn off any highlighted search matches
             3. jump two windows (should end us up at current buffer)
             4. go to last location in buffer ... not we have to do this
                after a delay ... 100 ms seems to be sufficient, increase
                if you don't get deisred result
        --]]
        --
        function()
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
        end,
        {
          desc = '[G]it [D]iff',
        }
      )
    end,
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- -- Rename the variable under your cursor.
          -- --  Most Language Servers support renaming across files, etc.
          -- map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          map('<leader>rn', function()
            local res = vim.lsp.buf_request_sync(0, 'textDocument/hover', vim.lsp.util.make_position_params(), 200)[1]
            if res and not res.error then
              --- @class I.Loc
              --- @field character integer
              --- @field line integer
              local file_buf = vim.api.nvim_get_current_buf()
              local s = res.result.range['start'] --- @type I.Loc
              local e = res.result.range['end'] --- @type I.Loc
              local old_name = vim.api.nvim_buf_get_text(0, s.line, s.character, e.line, e.character, {})[1]
              local row = vim.fn.winline()
              local col = vim.fn.wincol()
              local buf = vim.api.nvim_create_buf(false, true)
              local win = vim.api.nvim_open_win(buf, false, {
                relative = 'win',
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
                vim.lsp.buf.rename(new_name, { bufnr = file_buf })
                vim.schedule(function()
                  vim.cmd 'stopinsert'
                end)
              end, { buffer = buf })
            end
          end, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          vim.keymap.set('i', '<C-x>', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: Code Action' })

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
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
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- wraps normal diagnostics callback so we can get some extra information
          -- useful to tell whether or not we are still loading workspace
          vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, res, ctx)
            local uri = res.uri
            require('fidget').notify('-> ', '@comment.error', { key = 'diagnostic', annote = uri })
            vim.lsp.diagnostic.on_publish_diagnostics(err, res, ctx)
          end

          -- Lets give the hover information stuff a bit more style
          vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
            -- Use a sharp border with `FloatBorder` highlights
            border = 'single',
          })

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
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
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
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
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

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
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
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
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

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
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- unmap down,up and cr key, I still want to be able to move around text even if autocompletion is brought up
          ['<Down>'] = cmp.mapping(function(fallback)
            cmp.close()
            fallback()
          end, { 'i' }),
          ['<Up>'] = cmp.mapping(function(fallback)
            cmp.close()
            fallback()
          end, { 'i' }),
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
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  { -- My theme
    'rose-pine/neovim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      require('rose-pine').setup { styles = { italic = false } } -- This has to be before `vim.cmd.colorscheme` in order to work properly
      -- Load the colorscheme here.
      vim.cmd.colorscheme 'rose-pine'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
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

              -- local filename = MiniStatusline.section_filename { trunc_width = 140 }
              local filename = vim.fn.expand '%f'
              local filenam_hl = 'MiniStatuslineFilename'
              do
                if #filename > 24 then
                  local ff = vim.fn.split(filename, '/')
                  if #ff > 3 then
                    filename = ff[1] .. '/.../' .. ff[#ff - 1] .. '/' .. ff[#ff]
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
                { hl = workspace_hl, strings = { vim.fs.basename(root_dir) } },
                { hl = 'MiniStatuslineChanges', strings = { diff } },
                { hl = 'MiniStatuslineDiagnostics', strings = { diagnostics, lsp } },
                '%<', -- Mark general truncate point
                { hl = filenam_hl, strings = { filename } },
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

      -- -- You can configure sections in the statusline by overriding their
      -- -- default behavior. For example, here we set the section for
      -- -- cursor location to LINE:COLUMN
      -- ---@diagnostic disable-next-line: duplicate-set-field
      -- statusline.section_location = function()
      --   return '%2l:%-2v'
      -- end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      multiline_threshold = 1,
    },
    init = function()
      vim.keymap.set('n', '[c', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true, desc = 'jump to line of parent context' })
    end,
  },
  -- {
  --   'nvim-treesitter/nvim-treesitter-textobjects',
  --   opts = {},
  -- }, -- This plugin does not seem to work.

  { -- Highlight, edit, and navigate code
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

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    init = function()
      require('toggleterm').setup {
        -- size can be a number or function which is passed the current terminal
        open_mapping = [[<c-w>t]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
        start_in_insert = false,
        direction = 'vertical',
        size = 80,
      }
    end,
  },
  {
    'ggandor/leap.nvim',
    opts = {},
    config = function()
      local leap = require 'leap'
      leap.opts.labels = 'sfnjklhodweimbuyvrgtaqpcxzSFNJKLHODWEIMBUYVRGTAQPCXZ'
      leap.opts.safe_labels = ''
      vim.keymap.set({ 'n', 'x', 'o' }, '<leader>;', '<Plug>(leap)', { desc = '[F]ind Leap' })
      -- vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
      -- vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
      -- vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)')
    end,
  },
  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  -- { import = 'custom.plugins' },
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
