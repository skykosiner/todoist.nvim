local M = {}

---@param todo string
---@return string | integer
function M.get_todo_to_complete(todo)
  local first_split = vim.split(vim.split(todo, "☐ ")[2], "-")[1]
  return string.gsub(first_split, "%s+$", "")
end

return M
