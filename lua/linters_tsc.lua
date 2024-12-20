---@type LinterShim
return {
  name = 'tsc',
  cmd = 'npx',
  args = { 'tsc', '--noEmit', 'true', '--pretty', 'false' },

  res_to_diagnostics = function(res)
    ---@type table<string, vim.Diagnostic[]>
    local f_diagnostics = {}

    for line in res:gmatch '[^\r\n]+' do
      local filename, lnum, col, code, message = line:match '^(.+)%((%d+),(%d+)%)%s*:%s*(.+):%s*(.+)$'
      if f_diagnostics[filename] == nil then
        f_diagnostics[filename] = {}
      end
      -- f_diagnostics[filename][#f_diagnostics[filename] + 1] = {
      --   lnum = lnum and (lnum - 1) or 0,
      --   end_lnum = nil,
      --   col = col and (col - 1) or 0,
      --   end_col = nil,
      --   message = message and message or '?',
      --   code = code and code or nil,
      --   severity = 1,
      --   source = 'tsc',
      -- }

      -- NOTE: we just set empty list because our LSP already gives us the diagnostics
      --       ... we STILL run tsc though, because it correctly brings attention to the
      --       relevant files and loads them in so that our LSP can indeed find the issues
      --       with them
      f_diagnostics[filename] = {}
    end

    return f_diagnostics
  end,
}
