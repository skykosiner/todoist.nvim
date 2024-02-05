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
-- can source it from an environment
variable or you can just enter it in is a string
local todoist_api_key = os.getenv("TODOIST_API_TOKEN")
local todoist = require("todoist")
todoist:setup({
    api_key = todoist_api_key,
})

-- Veiew today's todo's
vim.keymap.set("n", "<leader>td", funciton()
    todoist:today()
end)
```
