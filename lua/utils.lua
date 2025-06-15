local function get_last_command()
  local result = vim.fn.system 'tail -n 1 ~/.bash_history'
  result = result:match '^%s*(.-)%s*$'
  return result
end

return {
  -- returns true if buffer is trivial
  --- @param buf integer -- 0 is current buffer
  --- @return boolean
  buf_is_trivial = function(buf)
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
  end,

  rename_terminal_to_last_command = function()
    vim.schedule(function()
      vim.wait(200) -- need this otherwise vim is too faaaaaaaaaaaaaast
      local last_cmd = get_last_command()
      local buf_number = vim.api.nvim_get_current_buf()
      if last_cmd then
        vim.cmd('file term://' .. buf_number .. '//' .. last_cmd)
      end
    end)
  end,

  arr = function(opts)
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
  end,
}
