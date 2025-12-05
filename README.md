# RCON Protocol implementation in Luvit

Using:

```lua
coroutine.wrap(function()
    local connection = require('rcon')('IP_ADRESS', PORT, 'PASSWORD')

    local ans = connection:sendCommand('status')
    print(ans)
end)()
```
