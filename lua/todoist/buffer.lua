local api = require "todoist.todoist-api"

---@class buffer
---@field create_floating_window_todos fun(api_key: string, tasks: todo[], project_view: boolean)
local M = {}

---@param api_key string
---@param tasks todo[]
---@param project_view boolean
function M.create_floating_window_todos(api_key, tasks, project_view)
  local height = 20
  local width = 90
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = 0
  local lineNum = 1

  for _, todo in ipairs(tasks) do
    if project_view then
      vim.api.nvim_buf_set_lines(buf, lines, -1, true, { "☐ " .. todo.content })
    else
      local todo_porject = api:get_project_by_id(api_key, todo.project_id)
      vim.api.nvim_buf_set_lines(buf, lines, -1, true,
        { "☐ " .. todo.content .. " - " .. todo.due.date .. " - " .. todo_porject.name })
    end

    lines = lines + 1
    lineNum = lineNum + 1
  end

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = (vim.api.nvim_get_option("lines") - height) / 2,
    col = (vim.api.nvim_get_option("columns") - width) / 2,
  }

  vim.api.nvim_open_win(buf, true, opts)
  vim.opt_local.wrap = true
  vim.opt_local.filetype = "markdown"
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.modifiable = false

  -- TODO: move cursor to the second column to avoid the checkbox

  vim.keymap.set("n", "q", ":q<CR>", { buffer = buf })

  -- TODO: Refresh the buffer after a task is completed

  vim.keymap.set("n", "<CR>", function()
    api:complete_task(api_key, vim.fn.getline("."))
  end, { buffer = buf })
end

return M
