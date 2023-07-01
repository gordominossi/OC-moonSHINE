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
                x = input.x,
                y = input.y,
                value = input.node.value,
                vertical = false,
                color = input.style.color,
            })
        end

        for _, child in ipairs(input.children) do
            local childList = self.execute(child)
            for _, paintObject in ipairs(childList) do
                table.insert(result,paintObject)
            end
        end

        return result
    end

    return self
end

return Paint
