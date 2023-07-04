---@param props Props | { title: string }
---@return Component
local function container(props)
    local title = props.title and (' ' .. props.title .. ' ') or ''
    return {
        'div',
        style = { width = props.width },
        '╭─' .. title .. string.rep('─', props.width - #title - 3) .. '╮',
        {
            style = { layout = 'inline' },
            {
                style = { width = 1 },
                string.rep('│', props.height - 2, ' '),
            },
            props.children or {},
            {
                x = props.width - 1,
                style = { width = 1 },
                string.rep('│', props.height - 2, ' '),
            },
        },
        '╰' .. string.rep('─', props.width - 2) .. '╯',
    }
end

return container
