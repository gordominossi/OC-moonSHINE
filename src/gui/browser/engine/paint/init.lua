local colors = require('lib.colors')
local merge = require('lib.language-extensions').mergeTables

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

        if (input.text) then
            table.insert(
                result,
                {
                    type = 'set',
                    x = input.x,
                    y = input.y,
                    value = input.text,
                    vertical = false,
                    color = input.color,
                    backgroundcolor = input.backgroundcolor,
                }
            )
        else
            table.insert(
                result,
                {
                    type = 'fill',
                    x = input.x,
                    y = input.y,
                    height = input.height,
                    width = input.width,
                    color = input.backgroundcolor,
                    backgroundcolor = input.color,
                }
            )

            local border = input.border
            local verticalBar = string.rep('|', input.height)
            local horizontalBar = string.rep('—', input.width - 2)
            local borderInstruction = {
                type = 'set',
                x = input.x,
                y = input.y,
                vertical = true,
                value = verticalBar,
                color = colors.border,
                backgroundcolor = input.backgroundcolor,
            }

            if border.left ~= 0 then
                table.insert(result, merge(borderInstruction))
            end

            if border.right ~= 0 then
                table.insert(
                    result,
                    merge(
                        borderInstruction,
                        { x = input.x + input.width - 1 }
                    )
                )
            end

            if border.top ~= 0 then
                table.insert(
                    result,
                    merge(
                        borderInstruction,
                        {
                            vertical = false,
                            value = '╭' .. horizontalBar .. '╮',
                        }
                    )
                )
            end

            if border.bottom ~= 0 then
                table.insert(
                    result,
                    merge(
                        borderInstruction,
                        {
                            y = input.y + input.height - 1,
                            vertical = false,
                            value = '╰' .. horizontalBar .. '╯',
                        }
                    )
                )
            end
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
