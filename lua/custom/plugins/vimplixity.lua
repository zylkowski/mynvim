local http = require 'socket.http'
local json = require 'vim._meta.json'
local ltn12 = require 'ltn12'

local response_body = {}
http.request {
  url = 'https://api.openai.com/v1/engines/davinci/completions',
  method = 'POST',
  headers = { ['Content-Type'] = 'application/json', ['Authorization'] = 'Bearer ' .. self.apikey },
  source = ltn12.source.string(json.encode {
    prompt = 'Tell me a joke',
    max_tokens = 50,
  }),
  sink = ltn12.sink.table(response_body),
}

vim.print(response_body)
