---@class LinterShim
---@field name string
---@field cmd string
---@field args string[]
---@field res_to_diagnostics fun(res: string): vim.Diagnostic[]

---@type table<string, boolean>
local running_linters = {}

---@type table<integer, boolean>
local active_diagnostic_ns = {}

return {

  --- clears the diagnostics associated with the linters
  clear_diagnostics = function()
    for ns, _ in pairs(active_diagnostic_ns) do
      vim.diagnostic.reset(ns)
      active_diagnostic_ns[ns] = nil
    end
  end,

  --- get list of namespaces
  ---@return integer[]
  get_namespaces = function()
    return vim.tbl_keys(active_diagnostic_ns)
  end,

  --- run the specified linter accross the entire workspace
  ---@param linter LinterShim
  ---@param on_complete? fun()
  run_linter = function(linter, on_complete)
    local progress = require 'fidget.progress'

    local p_handle = progress.handle.create {
      title = '',
      message = 'Launching ...',
      lsp_client = { name = linter.name },
    }

    -- NOTE: dont run linter if already running
    if running_linters[linter.name] then
      p_handle.message = linter.name .. ' is already running'
      p_handle:cancel()
      return
    end

    local linter_ns = vim.api.nvim_create_namespace('linter-runner-' .. linter.name)
    active_diagnostic_ns[linter_ns] = true

    running_linters[linter.name] = true

    local uv = vim.loop

    local chunks = {}
    local err_chunks = {}

    local stdout = uv.new_pipe()
    local stderr = uv.new_pipe()

    uv.spawn(linter.cmd, {
      args = linter.args,
      stdio = { nil, stdout, stderr },
    }, function(code, signal)
      -- on exit
    end)

    uv.read_start(stdout, function(err, data)
      assert(not err, err)
      if data then
        p_handle.message = 'Processing stdout ...'
        -- read data from stdout
        chunks[#chunks + 1] = data
      else
        -- stdout stream ended
        vim.schedule(function()
          local res = table.concat(chunks, '')
          local diagnostics = linter.res_to_diagnostics(res)

          for file, file_diagnostics in pairs(diagnostics) do
            local buf = vim.fn.bufnr(file, true)
            vim.fn.bufload(buf)
            for _, diagnostic in pairs(file_diagnostics) do
              diagnostic.message = '[' .. linter.name .. '] ' .. diagnostic.message
            end
            vim.diagnostic.set(linter_ns, buf, file_diagnostics, { severity_sort = true })
          end

          p_handle:finish()
          running_linters[linter.name] = nil
          if on_complete then
            on_complete()
          end
        end)
      end
    end)

    uv.read_start(stderr, function(err, data)
      assert(not err, err)
      if data then
        -- print('stderr chunk', stderr, data)
        err_chunks[#err_chunks + 1] = data
      else
        -- local res = table.concat(err_chunks, '')
        -- end of stream
      end
    end)
  end,
}
