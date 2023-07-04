local eventQueue = {}
local function buildEventAdder(name)
    return function(payload)
        table.insert(eventQueue, { topic = name, payload = payload })
    end
end

local moonSHINE = require('moonSHINE')
local activeModules = {
    moonSHINE.new(buildEventAdder('moonSHINE'))
}

local moduleOffset = 0
while true do
    ---@diagnostic disable-next-line: undefined-field
    os.sleep(0)

    local event = table.remove(eventQueue, 1)
    if event then
        for _, module in ipairs(activeModules) do
            if not pcall(module.processEvent, event) then
                module.lastFailed = os.time()
            end
        end
    else
        local module = activeModules[moduleOffset]
        if pcall(module.loop) then
            moduleOffset = (moduleOffset + 1) % #activeModules
        else
            module.lastFailed = os.time()
        end
    end

    local index = #activeModules
    while index > 0 do
        if activeModules[index].lastFailed then
            table.remove(activeModules, index)
        end
        index = index - 1
    end
end
