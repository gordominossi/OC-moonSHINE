---@param props Props | Progress
---@return Component
local function progressBar(props)
    local label = props.label or ''
    local current = props.current or 0
    local maximum = props.maximum or 0
    local minimum = props.minimum or 0

    local completionString = current .. ' / ' .. maximum
    local labelString = label ..
        string.rep(' ', 10 - #label - #completionString + 1) ..
        10 - #label - #completionString > 1 and
        completionString or
        ''

    local leftCap = (minimum >= 0 ~ current == minimum) and '◖' or '⨴'
    local rightCap = current == maximum and '◗' or '⨵'

    local lengthMultiplier = (props.width - 2) / (maximum - minimum)
    local negativePart = string.rep(
        '⨯',
        lengthMultiplier * (-math.max(minimum - current, minimum))
    )
    local fullPart = string.rep(
        '🬋',
        lengthMultiplier * (current)
    )
    local positivePart = string.rep(
        '⨯',
        lengthMultiplier * math.min(maximum - current, maximum)
    )

    local barString = leftCap ..
        negativePart ..
        fullPart ..
        positivePart ..
        rightCap


    return { labelString, barString }
end

return progressBar
