local M = {}

M.defaults = {
  -- The user command to run the search e.g. `:Tf <query>`
  user_command_prompt = "Tf",
  -- The user command to search for the word under the cursor e.g. `:Tfc`
  user_command_cursor = "Tfc",
  -- The user command to run the live search e.g. `:Tfl`
  user_command_live = "Tfl",
  -- The ripgrep options to use when searching, e.g. `{"--hidden", "--no-ignore-vcs"}`
  rg_options = nil,
}

M.options = {}

M.setup = function(config)
  M.options = vim.tbl_deep_extend("force", M.defaults, config or {})
end

M.get = function()
  return M.options
end

return M
