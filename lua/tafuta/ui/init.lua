local M = {}

-- input: create a floating window with a prompt
-- @param opts table: options for the prompt
-- @param opts.prompt string: the prompt text
-- @param opts.default string: the default text
-- @param opts.on_confirm function: callback when the user confirms the input
-- @param opts.on_change function: callback when the input changes
-- @param win_opts table: options for the floating window
-- @param win_opts.relative string: the relative position of the window
-- @param win_opts.row number: the row position of the window
-- @param win_opts.col number: the column position of the window
-- @param win_opts.width number: the width of the window
-- @param win_opts.height number: the height of the window
-- @param win_opts.focusable boolean: whether the window is focusable
-- @param win_opts.style string: the style of the window
-- @param win_opts.border string: the border of the window
-- @return nil
M.input = function(opts, win_opts)
  -- create a "prompt" buffer that will be deleted once focus is lost
  local buf = vim.api.nvim_create_buf(false, false)
  vim.bo[buf].buftype = "prompt"
  vim.bo[buf].bufhidden = "wipe"

  local default_text = opts.default or ""
  local on_confirm = opts.on_confirm or function() end

  -- defer the on_confirm callback so that it is
  -- executed after the prompt window is closed
  local deferred_callback = function(input)
    vim.defer_fn(function()
      on_confirm(input)
    end, 10)
  end

  -- set prompt and callback (CR) for prompt buffer
  vim.fn.prompt_setprompt(buf, "")
  vim.fn.prompt_setcallback(buf, deferred_callback)

  -- set some keymaps: CR confirm and exit, ESC in normal mode to abort
  vim.keymap.set({ "i", "n" }, "<CR>", "<CR><Esc>:close!<CR>:stopinsert<CR>", {
    silent = true,
    buffer = buf,
  })
  vim.keymap.set("n", "<esc>", "<cmd>close!<CR>", {
    silent = true,
    buffer = buf,
  })

  -- if on_change is provided, create an autocmd to call it
  if opts.on_change then
    vim.api.nvim_create_autocmd("TextChangedI", {
      buffer = buf,
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local text = table.concat(lines, "\n")
        opts.on_change(text)
      end,
    })
  end

  local default_win_opts = {
    title = win_opts.title or "Input",
    title_pos = "center",
    relative = "editor",
    row = vim.o.lines / 2 - 1,
    col = vim.o.columns / 2 - 25,
    width = 50,
    height = 1,
    focusable = true,
    style = "minimal",
    border = "rounded",
  }

  win_opts = vim.tbl_deep_extend("force", default_win_opts, win_opts)

  -- adjust window width so that there is always space
  -- for prompt + default text plus a little bit
  win_opts.width = #default_text + 5 < win_opts.width and win_opts.width or #default_text + 5

  -- open the floating window pointing to our buffer and show the prompt
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_win_set_option(win, "winhighlight", "Search:None")

  vim.cmd("startinsert")

  -- set the default text (needs to be deferred after the prompt is drawn)
  vim.defer_fn(function()
    vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, { default_text })
    vim.cmd("startinsert!") -- bang: go to end of line
  end, 5)
end

return M
