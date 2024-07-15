local api = require "todoist.todoist-api"
local buffer = require "todoist.buffer"

---@class TodoistConfig
---@field api_key string
---@field update_time integer

---@class Todoist
---@field config TodoistConfig
---@field setup fun(self: Todoist, config: TodoistConfig)
---@field today fun(self: Todoist)
---@field create_task fun(self: Todoist)
local Todoist = {}

Todoist.__index = Todoist

---@return Todoist
function Todoist:new()
  local todoist = setmetatable({
    config = {
      api_key = "",
      update_time = 300000,
    },
  }, self)

  return todoist
end

local new_todoist = Todoist:new()

---@param self Todoist
---@param config TodoistConfig
---@return Todoist
function Todoist.setup(self, config)
  self.config = config

  return self
end

---@param self Todoist
function Todoist.today(self)
  local todos = api:get_todays_todo(self.config.api_key, false)
  buffer.create_floating_window_todos(self.config.api_key, todos)
end

---@param self Todoist
function Todoist.view_project(self)
  local todos = api:view_porject(self.config.api_key)
  buffer.create_floating_window_todos(self.config.api_key, todos)
end

---@param self Todoist
function Todoist.create_task(self)
  api:create_task(self.config.api_key)
end

-- Start a vim timer to update the todo's every 5 minutes in the background
local timer = vim.loop.new_timer()
timer:start(0, new_todoist.config.update_time, function()
  vim.schedule(function()
    print("updating values", os.date())
    api:update_values(new_todoist.config.api_key)
  end)
end)

return new_todoist
