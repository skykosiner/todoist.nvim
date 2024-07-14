# Todoist.nvim
There are quite a few Todoist plugins for Neovim but none of them seemed to
work well for me, so I built this one my self. It's still a work in progress
and doesn't have the best code. Feel free to open a pr :)

* There is a timer running in the background that will use vim.timer and
vim.schedule to update the todo's every 5 minutes

## Installation
### Lazy
```lua
{
    "skykosiner/todoist.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim"
    }
}
```

## Basic setup
```lua
-- To get your api key in the first palace go to settings > integrations >
-- developer and copy your api token. to load your api key into the plugin you
-- can source it from an environment variable or you can just enter it in is a string
local todoist_api_key = os.getenv("TODOIST_API_TOKEN")
local todoist = require("todoist")
todoist:setup({
    api_key = todoist_api_key,
})
```

## Options
This function will get all the to-do's due for a day and pop them into a new
floating buffer in the center of your screen.

You can press enter, and it will mark a task as complete. It will not refresh
the buffer after you complete a task of right now.

```lua
vim.keymap.set("n", "<leader>td", function()
    -- the todoist function used here is the same varible defined in the setup
    todoist:today()
end)
```

This function will allow you to add to a to-do into todoist After you run the
function you'll be promoted to enter the title of your new task, then you'll be
asked what project you want to add the task to (just enter the number of the
project you want). Then you'll be promoted if you want to add a due date or
not. If you pick no the task will just be added, but if you pick yes then you
just enter your due date in natural language like you would inside the todoist
app itself.

```lua
vim.keymap.set("n", "<leader>tn", function()
    todoist:create_task()
end)
```

## More non-standard options
### Getting to-do's
If you want to get a table of today's to-do's and want to handle the table your
self then you can call the api function to get it.

```lua
require("todoist.todoist-api").get_todays_todos("your_api_key")
-- This function reutrns an array of the class todo

---@class todo
---@field id number
---@field content string
---@field is_completed boolean
---@field due due_date
---@field parent_id string
---@field priority string
---@field project_id number
```

You can also get the exact same result but all to-do's that are not completed.
```lua
require("todoist.todoist-api").get_active_todos("your_api_key")
-- This function returns the exact same array of the class todo as the last function
```

### Complete a to-do
```lua
require("todoist.todoist-api").complete_task("your_api_key", "name_of_todo_to_complete")
-- This function doesn't return anythig
```
