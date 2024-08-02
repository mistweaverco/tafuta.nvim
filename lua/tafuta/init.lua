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
  local user_command = CONFIG.get().user_command
  if user_command ~= nil then
    vim.api.nvim_create_user_command(user_command, function(a)
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

M.version = function()
  local neovim_version = vim.fn.execute("version")
  vim.notify(
    "Tafuta version: " .. GLOBALS.VERSION .. "\n\n" .. "Neovim version: " .. neovim_version,
    "info",
    { title = "Tafuta" }
  )
end

return M
