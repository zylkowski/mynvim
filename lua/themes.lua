utils = require 'utils'

--@type table<string, string>
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
  background_numberline = '#282838',
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
  background_numberline = '#282838',
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

  -- { key = 'FIX', group = 'MiniHipatternsFixme' },
  -- { key = 'FIXME', group = 'MiniHipatternsFixme' },
  -- { key = 'HACK', group = 'MiniHipatternsHack' },
  -- { key = 'WARN', group = 'MiniHipatternsHack' },
  -- { key = 'TODO', group = 'MiniHipatternsTodo' },
  -- { key = 'NOTE', group = 'MiniHipatternsNote' },
  -- TODO: example todo
  -- NOTE: example note
  -- FIXME: example fixme
  -- HACK: lalala
  --
  set_hl({
    -- 'TodoBgTODO',
    -- 'TodoBgNOTE',
    'MiniHiPatternsTodo',
  }, { fg = c.gray, bg = c.place })

  set_hl({
    -- 'TodoFgFIX',
    'MiniHiPatternsFixme',
  }, { fg = c.important_darker })

  set_hl({
    'TodoBgFIX',
    'TodoBgFIXME',
  }, { fg = c.gray, bg = c.important_darker })

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

vim.api.nvim_create_autocmd({ 'InsertEnter', 'TermEnter' }, {
  desc = 'Background change on entering insert mode',
  group = vim.api.nvim_create_augroup('arek-escape-insert', { clear = false }),
  callback = function()
    if utils.buf_is_trivial(0) then
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
