# todoist.nvim

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
vim.keymap.set("n", "<leader>td", function
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
vim.keymap.set("n", "<leader>tn", function
    todoist:create_task()
end)
```
