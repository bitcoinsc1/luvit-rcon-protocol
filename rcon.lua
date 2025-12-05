local ffi = require('ffi')
local net = require('net')

local uint32 = ffi.typeof('uint32_t*')
local array = ffi.typeof('uint8_t[?]')

local function formatRequest(options)
    local size = #options.data + 10
    local buf = array(size + 4)

    local data = ffi.cast(uint32, buf)
    data[0] = size
    data[1] = options.id
    data[2] = options.type

    ffi.copy(buf + 12, options.data)

    return ffi.string(buf, size + 4)
end

local function formatRespone(data)
    data = ffi.cast(uint32, data)

    return {
        size = data[0],
        id = data[1],
        type = data[2],
        body = ffi.string(ffi.cast('char*', data) + 12)
    }
end

return function(host, port, password)
    local cl = {}

    cl.socket = net.createConnection(port, host)

    function cl:GetID()
        self.id = self.id or 0
        self.id = self.id + 1

        return self.id
    end

    function cl:resetListeners()
        cl.socket:removeListener('data')
        cl.socket:removeListener('close')
    end

    function cl:sendCommand(body)
        local co = coroutine.running()

        if cl.socket.destroyed then
            coroutine.resume(co)

            return
        end

        local reqid = self:GetID()
        local ackid = self:GetID()

        self.socket:on('close', function()
            coroutine.resume(co)
        end)

        self.socket:write(formatRequest({
            id = reqid,
            type = 2,
            data = body
        }))

        self.socket:write(formatRequest({
            id = ackid,
            type = 0,
            data = ''
        }))

        local result = ''

        self.socket:on('data', function(data)
            data = formatRespone(data)

            if data.id == ackid then
                self:resetListeners()
                coroutine.resume(co, result)

                return
            end

            if data.id == reqid then
                result = result .. data.body
            end
        end)

        return coroutine.yield()
    end

    local co = coroutine.running()

    cl.socket:once('connect', function()
        cl.socket:write(formatRequest({
            id = cl:GetID(),
            type = 3,
            data = password
        }))
    end)

    cl.socket:on('data', function(data)
        data = formatRespone(data)

        if data.type == 2 then
            if data.id == -1 then
                print('Wrong password')
                cl.socket:destroy()
            elseif data.id == 1 then
                cl:resetListeners()
                coroutine.resume(co, cl)
            end
        end
    end)

    cl.socket:on('close', function()
        coroutine.resume(co)
    end)

    return coroutine.yield()
end