local GLOBALS = require("tafuta.globals")
local CONFIG = require("tafuta.config")
local UI = require("tafuta.ui")
local UTILS = require("tafuta.utils")
local M = {}

local rg_installed = vim.fn.executable("rg") == 1

local function focus_quickfix()
  -- Get the list of all windows
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    -- Check if the window is a quickfix list
    if vim.fn.getwininfo(win)[1].quickfix == 1 then
      -- Focus on the quickfix list window
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end

function M.live()
  UI.input({
    on_confirm = function(textstring)
      if textstring == "" then
        return
      end
      focus_quickfix()
    end,
    on_change = function(textstring)
      local t = UTILS.split_args(textstring)
      M.run(t, { live = true })
    end,
  }, {
    title = "Live-Search",
  })
  -- Save the current window ID
  local current_win = vim.api.nvim_get_current_win()
  -- Open the quickfix list
  vim.cmd("copen")
  -- Return focus to the previously focused window
  vim.api.nvim_set_current_win(current_win)
end

local async_run_live = vim.schedule_wrap(function(res)
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
  elseif code == 1 then
    vim.fn.setqflist({}, "r", {
      title = "Tafuta results",
      lines = {},
    })
  else
    vim.fn.setqflist({}, "r", {
      title = "Tafuta results",
      lines = {},
    })
  end
end)

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

local search = function(search_opts, opts)
  -- the search query is the last item in the table
  local search_query = search_opts[#search_opts]
  -- search flags are all the items in the table except the last one
  local search_flags = search_opts
  table.remove(search_flags, #search_flags)
  local search_command = { "rg", "--vimgrep" }
  local rg_options = CONFIG.get().rg_options or {}
  rg_options = vim.tbl_deep_extend("force", search_flags, rg_options)
  for _, option in ipairs(rg_options) do
    table.insert(search_command, option)
  end
  table.insert(search_command, search_query)
  if opts and opts.live then
    vim.system(search_command, { text = true }, async_run_live)
  else
    vim.system(search_command, { text = true }, async_run)
  end
end

M.setup = function(config)
  CONFIG.setup(config)
  local user_command_prompt = CONFIG.get().user_command_prompt
  local user_command_cursor = CONFIG.get().user_command_cursor
  local user_command_live = CONFIG.get().user_command_live
  if user_command_prompt ~= nil then
    vim.api.nvim_create_user_command(user_command_prompt, function(a)
      if a.args == "" then
        vim.notify("❌ No search query provided", vim.log.levels.INFO, { title = "Tafuta" })
        return
      end
      M.run(a.fargs)
    end, {
      nargs = "+",
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
  if user_command_live ~= nil then
    vim.api.nvim_create_user_command(user_command_live, function()
      M.live()
    end, {
      nargs = 0,
      desc = "Live search",
    })
  end
end

M.run = function(search_opts, opts)
  opts = opts or {}
  if not rg_installed then
    vim.notify("❌ ripgrep not found on the system", vim.log.levels.WARN, { title = "Tafuta" })
    return
  end
  if search_opts == nil then
    vim.notify("❌ no search query provided", vim.log.levels.INFO, { title = "Tafuta" })
    return
  end
  search(search_opts, opts)
end

M.cursor = function()
  local word = get_word_under_cursor()
  if word == nil then
    vim.notify("❌ no word under cursor", vim.log.levels.INFO, { title = "Tafuta" })
    return
  end
  M.run({ word })
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
