local Job = require "plenary.job"
local utils = require "todoist.utils"
--[[ local curl = require "plenary.curl"

curl.get("https://api.todoist.com/rest/v2/projects", {
  headers = {
    Authorization = "Bearer " .. api_key
  },
}) ]]
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

---@class api
---@field base_url string
---@field todos todo[] | nil
---@field projects project[] | nil
---@field update_time integer | nil
---@field update_values fun(self: api, api_key: string)
---@field get_projects fun(self: api, api_key: string): project[]
---@field get_active_todos fun(self: api, api_key: string): todo[]
---@field get_todays_todo fun(self: api, api_key: string): todo[]
---@field complete_task fun(self: api, api_key: string, todo_name: string)
---@field get_project_by_id fun(self: api, api_key: string, project_id: number): project | nil
---@field create_task fun(self: api, api_key: string)
---@field view_porject fun(self: api, api_key: string): todo[]
local api = {}

api.__index = api

---@reutrn @api
function api:new()
  local new_api = setmetatable({
    base_url = "https://api.todoist.com/rest/v2",
    todos = nil,
    projects = nil,
    update_time = nil
  }, self)

  return new_api
end

local new_api = api:new()

---@param self api
---@param api_key string
function api.update_values(self, api_key)
  if self.update_time ~= nil and os.time() - self.update_time < 300 then
    return
  elseif self.update_time == nil then
    self.update_time = os.time()
  else
    self.projects = self:get_projects(api_key)
    self.todo = self:get_active_todos(api_key)
    self.update_time = os.time()
  end
end

---@param self api
---@param api_key string
---@reutrn project[]
function api.get_projects(self, api_key)
  local projects = Job:new({
    command = "curl",
    args = { "-X", "GET", self.base_url .. "/projects", "-H", "Authorization: Bearer " .. api_key },
    on_exit = function(j, _)
      return j:result()
    end
  }):sync()

  self.projects = vim.fn.json_decode(projects)

  return vim.fn.json_decode(projects)
end

---@param self api
---@param api_key string
---@return todo[]
function api.get_active_todos(self, api_key)
  local projects = Job:new({
    command = "curl",
    args = { "-X", "GET", self.base_url .. "/tasks", "-H", "Authorization: Bearer " .. api_key },
    on_exit = function(j, _)
      return j:result()
    end
  }):sync()

  self.todos = vim.fn.json_decode(projects)

  return vim.fn.json_decode(projects)
end

---@param self api
---@param api_key string
---@return todo[]
function api.get_todays_todo(self, api_key)
  self:update_values(api_key)

  ---@type todo[]
  local today_todays = {}

  local projects = Job:new({
    command = "curl",
    args = { "-X", "GET", self.base_url .. "/tasks", "-H", "Authorization: Bearer " .. api_key },
    on_exit = function(j, _)
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

---@param self api
---@param api_key string
---@param todo_name string
function api.complete_task(self, api_key, todo_name)
  todo_name = utils.get_todo_to_complete(todo_name)

  local todos = self.todos or self:get_active_todos(api_key)
  for _, todo in ipairs(todos) do
    if todo.content == todo_name then
      Job:new({
        command = "curl",
        args = { "-X", "POST", self.base_url .. "/tasks/" .. todo.id .. "/close", "-H",
          "Authorization: Bearer " .. api_key },
      }):sync()
    end
  end
end

---@param self api
---@param api_key string
---@param project_id number
---@return project | nil
function api.get_project_by_id(self, api_key, project_id)
  self:update_values(api_key)

  local projects = self.projects or self:get_projects(api_key)

  for _, project in ipairs(projects) do
    if project.id == project_id then
      return project
    end
  end

  return nil
end

---@param self api
---@param api_key string
function api.create_task(self, api_key)
  self:update_values(api_key)

  local new_todo = vim.fn.input("New Todo Name: ")
  local porjects = self.projects or self:get_projects(api_key)
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
    args = { "-X", "POST", self.base_url .. "/tasks", "-H", "Authorization : Bearer " .. api_key, "-d",
      "content=" .. new_todo, "-d", "project_id=" .. project_to_add.id, "-d", "due_string=" .. due_date },
  }):sync()

  -- Update the todo table
  self.todos = self:get_active_todos(api_key)
end

---@param self api
---@param api_key string
---@return todo[]
function api.view_porject(self, api_key)
  self:update_values(api_key)

  local return_todo = {}
  local projects = self.projects or self:get_projects(api_key)
  local project_names = {}

  for idx, project in ipairs(projects) do
    table.insert(project_names, idx .. ". " .. project.name)
  end

  local project_selcected = tonumber(vim.fn.inputlist(project_names))
  local project_to_view = projects[project_selcected]
  local todos = self.todos or self:get_active_todos(api_key)

  for _, todo in ipairs(todos) do
    if todo.project_id == project_to_view.id then
      table.insert(return_todo, todo)
    end
  end

  return return_todo
end

return new_api
