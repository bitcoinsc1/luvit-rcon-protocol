# RCON Protocol implementation in Luvit

Using:

```lua
coroutine.wrap(function()
    local connection = require('rcon')('IP_ADDRESS', PORT, 'PASSWORD')

    local ans = connection:sendCommand('status')
    print(ans)
end)()
```
