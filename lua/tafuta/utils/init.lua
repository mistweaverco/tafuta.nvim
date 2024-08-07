local M = {}

M.split_args = function(input)
  local args = {}
  local current_arg = ""
  local escape = false

  for i = 1, #input do
    local char = input:sub(i, i)

    if escape then
      current_arg = current_arg .. char
      escape = false
    elseif char == "\\" then
      escape = true
    elseif char == " " then
      if #current_arg > 0 then
        table.insert(args, current_arg)
        current_arg = ""
      end
    else
      current_arg = current_arg .. char
    end
  end

  if #current_arg > 0 then
    table.insert(args, current_arg)
  end

  return args
end

return M
