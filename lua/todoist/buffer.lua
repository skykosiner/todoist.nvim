local api = require "todoist.todoist-api"

---@class buffer
---@field create_floating_window_todos fun(api_key: string, tasks: return_tasks)
local M = {}

---@param api_key string
---@param tasks return_tasks
function M.create_floating_window_todos(api_key, tasks)
  ---@param buf integer
  ---@param todos todo[]
  local function render_todos(buf, todos)
    vim.opt_local.modifiable = true
    local lines = {}

    for _, todo in ipairs(todos) do
      local line
      if tasks.project then
        line = "☐ " .. todo.content
      else
        local todo_porject = api:get_project_by_id(api_key, todo.project_id)

        if todo_porject ~= nil then
          line = "☐ " .. todo.content .. " - " .. todo.due.date .. " - " .. todo_porject.name
        else
          error("Your project name is nil" .. todo_porject .. todo.project_id)
        end
      end
      table.insert(lines, line)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    vim.opt_local.modifiable = false
  end

  ---@param buf integer
  local function fetch_and_render_todos(buf)
    if tasks.project then
      render_todos(buf, api:get_projects_tasks(api_key, tasks.project_id).tasks)
    else
      render_todos(buf, api:get_todays_todo(api_key, true).tasks)
    end
  end

  local height = 20
  local width = 90
  local buf = vim.api.nvim_create_buf(false, true)

  render_todos(buf, tasks.tasks)

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

  vim.keymap.set("n", "q", ":q<CR>", { buffer = buf })

  -- TODO: Refresh the buffer after a task is completed

  vim.keymap.set("n", "<CR>", function()
    api:complete_task(api_key, vim.fn.getline("."))
    fetch_and_render_todos(buf)
  end, { buffer = buf })
end

return M
