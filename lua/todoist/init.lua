local api = require "todoist.todoist-api"
local buffer = require "todoist.buffer"

---@class TodoistConfig
---@field api_key string

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
    },
  }, self)

  return todoist
end

local new_todoist = Todoist:new()

--@param self Todoist
--@param config TodoistConfig
--@return Todoist
function Todoist.setup(self, config)
  if self ~= new_todoist then
    self = new_todoist
  end

  self.config.api_key = config.api_key

  return self
end

--@param self Todoist
function Todoist.today(self)
  local todos = api.get_todays_todo(self.config.api_key)
  buffer.create_floating_window_todos(self.config.api_key, todos)
end

--@param self Todoist
function Todoist.create_task(self)
  api.create_task(self.config.api_key)
end

return new_todoist
