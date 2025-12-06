# RCON Protocol implementation in Luvit

How to use:

```lua
coroutine.wrap(function()
    local connection = require('rcon')('IP_ADDRESS', PORT, 'PASSWORD')

    local ans = connection:sendCommand('help')
    print(ans)
end)()
```

https://minecraft.wiki/w/RCON
