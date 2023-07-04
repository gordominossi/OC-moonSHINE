---@enum MoonshineKeys
local moonshineKeys = {
    InfusionPatternFound = 'pattern found',
    EssentiaPatternNotFound = 'essentia pattern not found',
    EssentiaRequested = 'essentia requested',
    InfusionStarted = 'infusion started',
    InfusionUpdated = 'infusion updated',
    InfusionSucceeded = 'infusion succeeded',
    InfusionFailed = 'infusion failed',
}
local switch = setmetatable(
    {
        ---@param payload InfusionPatternFoundPayload
        [moonshineKeys.InfusionPatternFound] = function(payload)
            return payload
        end,
        ---@param payload EssentiaPatternNotFoundPayload
        [moonshineKeys.EssentiaPatternNotFound] = function(payload)
            return payload
        end,
        ---@param payload EssentiaRequestedPayload
        [moonshineKeys.EssentiaRequested] = function(payload)
            return payload
        end,
        ---@param payload InfusionStartedPayload
        [moonshineKeys.InfusionStarted] = function(payload)
            return payload
        end,
        ---@param payload InfusionUpdatedPayload
        [moonshineKeys.InfusionUpdated] = function(payload)
            return payload
        end,
        ---@param payload InfusionFailedPayload
        [moonshineKeys.InfusionFailed] = function(payload)
            return payload
        end,
        ---@param payload InfusionSucceededPayload
        [moonshineKeys.InfusionSucceeded] = function(payload)
            return payload
        end,
    }, {
        __index = function(table, key)
            return table[key] or
                function()
                end
        end
    }
)

---@param event Event
local function processEvent(event)
    if event.topic ~= 'moonSHINE' then
        return
    end

    return switch[event.key](event.payload)
end

return processEvent
