---@type Paint
local Paint = {}

---@return Paint
function Paint.new()
    ---@class Paint
    local self = {}

    ---@param input LayoutObject
    ---@return PaintObject[]
    function self.execute(input)
        ---@type PaintObject[] list
        local result = {}

        if (input.node.type == 'text') then
            table.insert(result, {
                type = 'set',
                x = input.x,
                y = input.y,
                value = input.node.value,
                vertical = false,
                color = input.color,
                backgroundcolor = input.backgroundcolor,
            })
        elseif (input.node.type == 'div') then
            table.insert(result, {
                type = 'fill',
                x = input.x,
                y = input.y,
                height = input.height,
                width = input.width,
                color = input.backgroundcolor,
                backgroundcolor = input.backgroundcolor,
            })
        end

        for _, child in ipairs(input.children) do
            local childList = self.execute(child)
            for _, paintObject in ipairs(childList) do
                table.insert(result, paintObject)
            end
        end

        return result
    end

    return self
end

return Paint
