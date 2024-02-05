local Job = require "plenary.job"
local utils = require "todoist.utils"

---@class due_date
---@field date string
---@field is_recurring boolean

---@class todo
---@field id number
---@field content string
---@field is_completed boolean
---@field due due_date
---@field parent_id string
---@field priority string
---@field project_id number

---@class project
---@field id number
---@field name string

local api = {
  base_url = "https://api.todoist.com/rest/v2"
}

---@param api_key string
---@reutrn project[]
function api.get_projects(api_key)
  local projects = Job:new({
    command = "curl",
    args = { "-X", "GET", api.base_url .. "/projects", "-H", "Authorization: Bearer " .. api_key },
    on_exit = function(j, return_val)
      return j:result()
    end
  }):sync()

  return vim.fn.json_decode(projects)
end

---@param api_key string
---@return todo[]
function api.get_active_todos(api_key)
  local projects = Job:new({
    command = "curl",
    args = { "-X", "GET", api.base_url .. "/tasks", "-H", "Authorization: Bearer " .. api_key },
    on_exit = function(j, return_val)
      return j:result()
    end
  }):sync()

  return vim.fn.json_decode(projects)
end

---@param api_key string
---@returns todo[]
function api.get_todays_todo(api_key)
  ---@type todo[]
  local today_todays = {}

  local projects = Job:new({
    command = "curl",
    args = { "-X", "GET", api.base_url .. "/tasks", "-H", "Authorization: Bearer " .. api_key },
    on_exit = function(j, return_val)
      return j:result()
    end
  }):sync()

  ---@type todo[]
  local todos = vim.fn.json_decode(projects)

  for _, todo in ipairs(todos) do
    if todo.due ~= vim.NIL then
      local date = os.date("%Y-%m-%d")
      -- Add the todo's to the list if it's due today or overdue
      if todo.due.date == date then
        table.insert(today_todays, todo)
      elseif todo.is_completed == false and todo.due.date < date then
        table.insert(today_todays, todo)
      end
    end
  end

  return today_todays
end

---@param api_key string
---@param todo_name string
function api.complete_task(api_key, todo_name)
  todo_name = utils.get_todo_to_complete(todo_name)

  local todos = api.get_active_todos(api_key)
  for _, todo in ipairs(todos) do
    if todo.content == todo_name then
      Job:new({
        command = "curl",
        args = { "-X", "POST", api.base_url .. "/tasks/" .. todo.id .. "/close", "-H",
          "Authorization: Bearer " .. api_key },
      }):sync()
    end
  end
end

---@param api_key string
---@param project_id number
---@return project
function api.get_project_by_id(api_key, project_id)
  local projects = api.get_projects(api_key)

  for _, project in ipairs(projects) do
    if project.id == project_id then
      return project
    end
  end
end

---@param api_key string
function api.create_task(api_key)
  local new_todo = vim.fn.input("New Todo Name: ")
  local porjects = api.get_projects(api_key)
  local project_names = {}

  for idx, project in ipairs(porjects) do
    table.insert(project_names, idx .. ". " .. project.name)
  end

  local project_selcected = tonumber(vim.fn.inputlist(project_names))
  local project_to_add = porjects[project_selcected]

  local due_date = vim.fn.input("Do you want to asign a due date? (y/n): ")

  if due_date == "y" then
    due_date = vim.fn.input("Enter the due date in natuarl language: ")
  elseif due_date == "n" then
    due_date = ""
  end

  Job:new({
    command = "curl",
    args = { "-X", "POST", api.base_url .. "/tasks", "-H", "Authorization : Bearer " .. api_key, "-d",
      "content=" .. new_todo, "-d", "project_id=" .. project_to_add.id, "-d", "due_string=" .. due_date },
  }):sync()
end

return api
