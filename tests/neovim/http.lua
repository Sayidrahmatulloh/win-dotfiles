-- Tests only a disposable localhost server; it never sends project requests.
-- nvim --headless -i NONE -n -u config/nvim/init.lua -l tests/neovim/http.lua
local server, fixture

local function check()
  local root = assert(vim.fs.root(debug.getinfo(1, "S").source:sub(2), "setup.json"), "Repository root not found")
  vim.cmd.lcd(root)
  require("lazy").load({ plugins = { "kulala.nvim" } })
  local client, api = require("kulala"), require("kulala.api")
  local responses, requests = {}, {}
  api.on("after_request", function(result)
    responses[#responses + 1] = result
  end)

  server = assert(vim.uv.new_tcp())
  assert(server:bind("127.0.0.1", 0))
  local port = server:getsockname().port
  assert(server:listen(8, function(err)
    assert(not err, err)
    local peer = assert(vim.uv.new_tcp())
    assert(server:accept(peer))
    local received = ""
    peer:read_start(function(read_err, data)
      assert(not read_err, read_err)
      if not data then
        return
      end
      received = received .. data
      if not received:find("\r\n\r\n", 1, true) then
        return
      end
      peer:read_stop()
      requests[#requests + 1] = received:match("^GET ([^ ]+)")
      local body = '{"id":42,"ok":true}'
      peer:write(
        "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: "
          .. #body
          .. "\r\nConnection: close\r\n\r\n"
          .. body,
        function()
          peer:shutdown(function()
            peer:close()
          end)
        end
      )
    end)
  end))

  fixture = vim.fn.tempname() .. ".http"
  vim.fn.writefile({
    "@api = http://127.0.0.1:" .. port,
    "",
    "### First request",
    "# @name first",
    "GET {{api}}/first",
    "",
    "### Chained request",
    "GET {{api}}/items/{{first.response.body.$.id}}",
  }, fixture)
  vim.cmd.edit(vim.fn.fnameescape(fixture))
  local request_buf, request_win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
  assert(vim.bo[request_buf].filetype == "http", "HTTP filetype was not detected")
  assert(vim.fn.maparg("<leader>rq", "n") ~= "", "Send request mapping is missing")
  local editor_height = vim.api.nvim_win_get_height(request_win)
  local editor_width = vim.api.nvim_win_get_width(request_win)

  vim.api.nvim_win_set_cursor(request_win, { 5, 0 })
  client.run()
  assert(
    vim.wait(15000, function()
      return #responses == 1
    end, 20),
    "First HTTP response timed out"
  )
  assert(responses[1].response.response_code == 200, vim.inspect(responses[1]))
  assert(vim.json.decode(responses[1].body).id == 42, "Response JSON was not preserved")
  local response_win = vim.api.nvim_get_current_win()
  local window = vim.api.nvim_win_get_config(response_win)
  assert(window.relative == "editor", "HTTP response did not open as a floating window")
  assert(window.border[1] == "╭" and window.border[3] == "╮", "Response border is not rounded")
  assert(vim.api.nvim_win_get_height(request_win) == editor_height, "Response resized the editor height")
  assert(vim.api.nvim_win_get_width(request_win) == editor_width, "Response resized the editor width")
  local close_response = vim.fn.maparg("q", "n", false, true).callback
  assert(type(close_response) == "function", "Response close mapping is missing")
  close_response()
  assert(not vim.api.nvim_win_is_valid(response_win), "Response window did not close")
  assert(vim.api.nvim_buf_is_valid(request_buf), "Closing the response deleted the HTTP file buffer")

  vim.api.nvim_set_current_win(request_win)
  vim.api.nvim_win_set_buf(request_win, request_buf)
  vim.api.nvim_win_set_cursor(request_win, { 8, 0 })
  client.run()
  assert(
    vim.wait(15000, function()
      return #responses == 2
    end, 20),
    "Chained HTTP response timed out"
  )
  assert(requests[1] == "/first" and requests[2] == "/items/42", vim.inspect(requests))
  assert(responses[2].response.response_code == 200, vim.inspect(responses[2]))
  print("HTTP floating response preserves editor size; request variables and response chaining OK")
end

local ok, err = pcall(check)
if server and not server:is_closing() then
  server:close()
end
if fixture then
  vim.fn.delete(fixture)
end
if not ok then
  print(err)
  vim.cmd("cquit 1")
end
