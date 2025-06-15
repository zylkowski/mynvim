return {
  put = function()
    vim.fn.setqflist({
      {
        filename = vim.fn.expand '%',
        lnum = vim.fn.line '.',
        col = vim.fn.col '.',
        text = vim.fn.getline '.',
      },
    }, 'a')
    -- vim.cmd 'botright copen | wincmd p'
  end,
  delete = function()
    local qflist = vim.fn.getqflist()
    local idx = vim.fn.getqflist({ idx = 0 }).idx

    if idx > 0 and idx <= #qflist then
      table.remove(qflist, idx)
      vim.fn.setqflist(qflist, 'r')
      vim.notify('Removed entry at index ' .. idx, vim.log.levels.INFO)
    else
      vim.notify('Invalid quickfix entry', vim.log.levels.ERROR)
    end
  end,
}
