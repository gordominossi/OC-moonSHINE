---@enum InfusionEventKeys
local infusionKeys = {
    InfusionPatternFound = 'pattern found',
    EssentiaOrderFailed = 'essentia order failed',
    EssentiaRequested = 'essentia requested',
    InfusionUpdated = 'infusion updated',
    InfusionSucceeded = 'infusion succeeded',
    InfusionFailed = 'infusion failed',
}

---@type { [InfusionEventKeys]: string }
local messages = {
    [infusionKeys.InfusionPatternFound] = 'Found items for ',
    [infusionKeys.EssentiaOrderFailed] = 'Couldn\'t order essentia for ',
    [infusionKeys.EssentiaRequested] = 'Requested essentia for ',
    [infusionKeys.InfusionUpdated] = 'Infusing ',
    [infusionKeys.InfusionFailed] = 'Failed to infuse ',
    [infusionKeys.InfusionSucceeded] = 'Infused ',
}

local altars = {}
---@param event Event | { payload: InfusionEventPayload }
---@return AltarModel
local getState = function(state, event)
    if event.topic ~= 'infusion' then
        return state
    end

    local message = messages[event.key]
    if not message then
        return state
    end

    local newState = { table.unpack(state) }
    local payload = event.payload

    local altarIndex = 0
    for index, altar in ipairs(altars) do
        if altar.altarId == payload.altarId then
            altarIndex = index
            break
        end
    end

    local newAltar = {
        altarId = payload.altarId,
        message = message .. payload.output .. '.',
        progressBars = payload.progressBars or {}
    }

    if altarIndex == 0 then
        if #altars < 6 then
            table.insert(altars, newAltar)
            altarIndex = #altars
        end
    end

    newState[altarIndex] = newAltar

    return newState
end


return getState
