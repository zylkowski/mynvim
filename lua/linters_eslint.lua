---@class EslintMessage
---@field column integer
---@field line integer
---@field endColumn integer
---@field endLine integer
---@field severity integer
---@field message string
---@field ruleId string

---@class EslintEntry
---@field errorCount integer
---@field filePath string
---@field messages EslintMessage[]

---@type LinterShim
return {
  name = 'eslint',

  -- NOTE: we set to src and lib because that is what NEXT does by default
  cmd = 'npx',
  args = { 'eslint', '--format', 'json', 'src', 'lib' },

  res_to_diagnostics = function(res)
    ---@type boolean, EslintEntry[]
    local ok, json = pcall(vim.json.decode, res, { luanil = { object = true, array = true } })
    if not ok then
      return {}
    end

    local eslint_severities = {
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.ERROR,
    }

    ---@type table<string, vim.Diagnostic[]>
    local file_diagnostics = {}

    for _, k in ipairs(json) do
      if k.errorCount > 0 then
        local diagnostics = {}
        for _, msg in ipairs(k.messages) do
          ---@type vim.Diagnostic
          local diagnostic = {
            lnum = msg.line and (msg.line - 1) or 0,
            end_lnum = msg.endLine and (msg.endLine - 1) or nil,
            col = msg.column and (msg.column - 1) or 0,
            end_col = msg.endColumn and (msg.endColumn - 1) or nil,
            message = msg.message,
            code = msg.ruleId,
            severity = eslint_severities[msg.severity],
            source = 'eslint',
          }
          diagnostics[#diagnostics + 1] = diagnostic
        end
        file_diagnostics[k.filePath] = diagnostics
      end
    end

    return file_diagnostics
  end,
}
