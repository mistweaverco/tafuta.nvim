local M = {}

M.defaults = {
  -- The user command to run the search e.g. `:Tf <query>`
  user_command = "Tf",
}

M.options = {}

M.setup = function(config)
  M.options = vim.tbl_deep_extend("force", M.defaults, config or {})
end

M.get = function()
  return M.options
end

return M
