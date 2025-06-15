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
