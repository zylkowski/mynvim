vim.keymap.set('v', '<leader>lc', ':lua OllamaReplace()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lp', ':lua OllamaPut()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lj', ':lua OllamaRandom()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lr', ':lua OllamaCodeReview()<CR>', { noremap = true, silent = true })

function OllamaRandom()
  local bufnr = vim.api.nvim_get_current_buf()
  local parentwin = vim.api.nvim_get_current_win()

  local start_pos = vim.fn.getpos '.'

  local langs = { 'rust', 'ts', 'js', 'lua', 'brainfuck', 'fortran', 'python', 'java', 'c++', 'go', 'php', 'haskell', 'ocaml' }
  local randomIndex = math.random(1, #langs)
  local randomLanguage = langs[randomIndex]
  vim.print(randomLanguage)
  local new_content =
    ollama_gen_code('Generate a random program in ' .. randomLanguage .. "programming language, random number(don't use it):" .. math.random(5000), 1.2)

  vim.api.nvim_set_current_win(parentwin)
  vim.api.nvim_buf_set_text(bufnr, start_pos[2] - 1, start_pos[3] - 1, start_pos[2] - 1, start_pos[3] - 1, vim.split(new_content, '\n'))
end

function OllamaPut()
  local bufnr = vim.api.nvim_get_current_buf()
  local parentwin = vim.api.nvim_get_current_win()

  local start_pos = vim.fn.getpos '.'

  local row = vim.fn.winline()
  local col = vim.fn.wincol()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'win',
    title = 'LLM put code',
    row = row,
    col = col,
    width = 75,
    height = 3,
    border = 'rounded',
    style = 'minimal',
  })

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)

  vim.api.nvim_set_current_win(win)
  vim.api.nvim_feedkeys('i', 'n', true)
  vim.keymap.set({ 'n' }, '<Esc><Esc>', ':q<cr>', { buffer = buf })
  vim.keymap.set({ 'n' }, '<CR>', function()
    local prompt = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 3, false), '\n')
    vim.fn.setreg('p', prompt, 'c')

    vim.cmd 'q'
    local new_content = ollama_gen_code(prompt)

    vim.api.nvim_set_current_win(parentwin)
    vim.api.nvim_buf_set_text(bufnr, start_pos[2] - 1, start_pos[3] - 1, start_pos[2] - 1, start_pos[3] - 1, vim.split(new_content, '\n'))
  end, { buffer = buf })
end

function OllamaReplace()
  --
  local bufnr = vim.api.nvim_get_current_buf()
  local parentwin = vim.api.nvim_get_current_win()

  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_pos[2] - 1, end_pos[2], false)

  if #lines == 0 then
    return
  end

  -- Trim to selected columns
  lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  lines[1] = string.sub(lines[1], start_pos[3])
  local content = table.concat(lines, '\n')

  local row = vim.fn.winline()
  local col = vim.fn.wincol()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'win',
    title = 'LLM change the code',
    row = row,
    col = col,
    width = 75,
    height = 3,
    border = 'rounded',
    style = 'minimal',
  })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)

  vim.api.nvim_set_current_win(win)
  vim.api.nvim_feedkeys('i', 'n', true)
  vim.keymap.set({ 'n' }, '<Esc><Esc>', ':q<cr>', { buffer = buf })
  vim.keymap.set({ 'n' }, '<CR>', function()
    local prompt = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 3, false), '\n')
    vim.fn.setreg('p', prompt, 'c')

    vim.cmd 'q'
    local new_content = ollama_change_code(content, prompt)

    local end_col = end_pos[3] - 1
    local line = vim.api.nvim_buf_get_lines(bufnr, end_pos[2] - 1, end_pos[2], false)[1]
    if end_col > #line then
      end_col = #line
    end

    vim.api.nvim_set_current_win(parentwin)
    vim.api.nvim_buf_set_text(bufnr, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_col, vim.split(new_content, '\n'))
  end, { buffer = buf })
end

function OllamaCodeReview()
  --
  local bufnr = vim.api.nvim_get_current_buf()
  local parentwin = vim.api.nvim_get_current_win()

  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_pos[2] - 1, end_pos[2], false)

  if #lines == 0 then
    return
  end

  -- Trim to selected columns
  lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  lines[1] = string.sub(lines[1], start_pos[3])
  local content = table.concat(lines, '\n')

  local row = vim.fn.winline()
  local col = vim.fn.wincol()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'win',
    title = 'LLM change the code',
    row = row,
    col = col,
    width = 75,
    height = 3,
    border = 'rounded',
    style = 'minimal',
  })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)

  vim.api.nvim_set_current_win(win)
  vim.api.nvim_feedkeys('i', 'n', true)
  vim.keymap.set({ 'n' }, '<Esc><Esc>', ':q<cr>', { buffer = buf })
  vim.keymap.set({ 'n' }, '<CR>', function()
    local prompt = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 3, false), '\n')
    vim.fn.setreg('p', prompt, 'c')

    vim.cmd 'q'
    local new_content = ollama_code_review(content)

    local end_col = end_pos[3] - 1
    local line = vim.api.nvim_buf_get_lines(bufnr, end_pos[2] - 1, end_pos[2], false)[1]
    if end_col > #line then
      end_col = #line
    end

    vim.api.nvim_set_current_win(parentwin)
    vim.api.nvim_buf_set_text(bufnr, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_col, vim.split(new_content, '\n'))
  end, { buffer = buf })
end

function ollama_change_code(content, prompt)
  local json_body = vim.fn.json_encode {
    stream = false,
    model = 'gemma3:27b',
    options = {
      temperature = 0,
      num_ctx = 4096,
    },
    messages = {
      {
        role = 'system',
        content = [[You are code transforming agent. 
                    Your purpose is to transform following code according to user needs.
                    In your response DO NOT contain any explainations or comments. 
                    Output **ONLY** code and KEEP the formatting unchanged. STRICTLY Do **NOT** contain any code blocks with ```<name of the language>, return ONLY raw code.\n]]
          .. content,
      },
      { role = 'user', content = prompt },
    },
  }

  local response = vim.fn.system {
    'curl',
    '-s',
    '-X',
    'POST',
    '-H',
    'Content-Type: application/json',
    '-d',
    json_body,
    'localhost:11434/api/chat',
  }

  local resp = vim.fn.json_decode(response)

  return strip_code_blocks(resp.message.content)
end

function ollama_gen_code(prompt, temp, seed)
  temp = temp or 0
  seed = seed or math.random(1000000)
  local json_body = vim.fn.json_encode {
    stream = false,
    model = 'gemma3:27b',
    options = {
      seed = seed,
      temperature = temp,
      num_ctx = 4096,
    },
    messages = {
      {
        role = 'system',
        content = [[You are a code generation agent. Output only raw code. Never include triple backticks (```), comments, or explanations. Output code as plain text only. Violating this is an error.]],
      },
      { role = 'user', content = prompt },
    },
  }

  local response = vim.fn.system {
    'curl',
    '-s',
    '-X',
    'POST',
    '-H',
    'Content-Type: application/json',
    '-d',
    json_body,
    'localhost:11434/api/chat',
  }

  local resp = vim.fn.json_decode(response)

  return strip_code_blocks(resp.message.content)
end

function ollama_code_review(content, prompt)
  local json_body = vim.fn.json_encode {
    stream = false,
    model = 'gemma3:27b',
    options = {
      temperature = 0,
      num_ctx = 4096,
    },
    messages = {
      {
        role = 'system',
        content = [[You are code review agent. Review the code supplied to you, mention potential pitfalls in the code. Be strict. Tend towards short but precise sentences.]]
          .. content,
      },
      { role = 'user', content = prompt },
    },
  }

  local response = vim.fn.system {
    'curl',
    '-s',
    '-X',
    'POST',
    '-H',
    'Content-Type: application/json',
    '-d',
    json_body,
    'localhost:11434/api/chat',
  }

  local resp = vim.fn.json_decode(response)

  return strip_code_blocks(resp.message.content)
end

function strip_code_blocks(s)
  local lines = {}
  for line in string.gmatch(s, '[^\n]+') do
    table.insert(lines, line)
  end

  if #lines > 0 and string.sub(lines[1], 1, 3) == '```' then
    table.remove(lines, 1)
  end

  if #lines > 0 and string.sub(lines[#lines], 1, 3) == '```' then
    table.remove(lines, #lines)
  end

  return table.concat(lines, '\n')
end
