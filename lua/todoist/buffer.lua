local api = require "todoist.todoist-api"
local M = {}

---@param api_key string
---@param tasks todo[]
function M.create_floating_window_todos(api_key, tasks)
  local width = 90
  local height = 20
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = 0
  local lineNum = 1

  vim.g.api_key = api_key

  for _, todo in ipairs(tasks) do
    vim.api.nvim_buf_set_lines(buf, lines, -1, true, { "☐ " .. todo.content })
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

  -- TODO: move cursor to the second column to avoid the checkbox

  -- Close window with q
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })

  -- TODO: Refresh the buffer after a task is completed
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>",
    ":lua require('todoist.todoist-api').complete_task(vim.g.api_key, vim.fn.getline('.'))<CR>",
    { noremap = true, silent = true })
end

return M
