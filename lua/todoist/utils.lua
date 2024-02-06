---@class utils
---@feild get_todo_to_complete fun(todo: string): string | integer
local utils = {}

---@param todo string
---@return string | integer
function utils.get_todo_to_complete(todo)
  local first_split = vim.split(vim.split(todo, "☐ ")[2], "-")[1]
  return string.gsub(first_split, "%s+$", "")
end

return utils
