local GLOBALS = require("tafuta.globals")
local CONFIG = require("tafuta.config")
local M = {}

local rg_installed = vim.fn.executable("rg") == 1

local async_run = vim.schedule_wrap(function(res)
  local code = res.code
  if code == 0 then
    local matches = vim.split(res.stdout, "\n", { trimempty = true })
    if vim.tbl_isempty(matches) then
      vim.notify("❌ no match", vim.log.levels.INFO, { title = "Tafuta" })
      return
    end
    vim.fn.setqflist({}, "r", {
      title = "Tafuta results (" .. #matches .. ")",
      lines = matches,
    })
    vim.cmd("copen")
  elseif code == 1 then
    vim.notify("❌ no match", vim.log.levels.INFO, { title = "Tafuta" })
  else
    vim.notify("💀 error occurred", vim.log.levels.ERROR, { title = "Tafuta" })
  end
end)

local function get_word_under_cursor()
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  if col == #line then
    col = col - 1
  end
  local start_col, end_col = line:find("%w+", col + 1)
  if start_col and end_col then
    return line:sub(start_col, end_col)
  else
    return nil
  end
end

local search = function(search_query)
  local search_command = { "rg", "--vimgrep" }
  local rg_options = CONFIG.get().rg_options
  if rg_options ~= nil then
    for _, option in ipairs(rg_options) do
      table.insert(search_command, option)
    end
  end
  table.insert(search_command, search_query)
  vim.system(search_command, { text = true }, async_run)
end

M.setup = function(config)
  CONFIG.setup(config)
  local user_command_prompt = CONFIG.get().user_command_prompt
  local user_command_cursor = CONFIG.get().user_command_cursor
  if user_command_prompt ~= nil then
    vim.api.nvim_create_user_command(user_command_prompt, function(a)
      if a.args == "" then
        vim.notify("❌ No search query provided", vim.log.levels.INFO, { title = "Tafuta" })
        return
      end
      M.run(a.args)
    end, {
      nargs = "?",
      desc = "Tf, blazingly fast ⚡ search 🔍 using ripgrep 🦀",
    })
  end
  if user_command_cursor ~= nil then
    vim.api.nvim_create_user_command(user_command_cursor, function()
      M.cursor()
    end, {
      nargs = 0,
      desc = "Search for the word under the cursor",
    })
  end
end

M.run = function(search_query)
  if not rg_installed then
    vim.notify("❌ ripgrep not found on the system", vim.log.levels.WARN, { title = "Tafuta" })
    return
  end
  if search_query == nil then
    search_query = vim.fn.input("Search: ")
  end
  search(search_query)
end

M.cursor = function()
  local word = get_word_under_cursor()
  if word == nil then
    vim.notify("❌ no word under cursor", vim.log.levels.INFO, { title = "Tafuta" })
    return
  end
  search(word)
end

M.version = function()
  local neovim_version = vim.fn.execute("version")
  vim.notify(
    "Tafuta version: " .. GLOBALS.VERSION .. "\n\n" .. "Neovim version: " .. neovim_version,
    "info",
    { title = "Tafuta" }
  )
end

return M
