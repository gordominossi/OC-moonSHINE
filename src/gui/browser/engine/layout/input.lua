local gpu = require('component').gpu

local BaseLayout = require('src.gui.browser.engine.layout.base')

---@type InputLayout
local InputLayout = {}
---@param node Element
---@param parent Layout
---@param previousSibling? Layout
---@return InputLayout
function InputLayout.new(node, parent, previousSibling)
    ---@class InputLayout : Layout
    ---@field node Element
    local self = BaseLayout.new(node, parent, previousSibling)

    function self.layout()
        self.width = self.node.props.style.width or 0
        self.height = self.node.props.style.height or 1

        if self.previousSibling then
            self.x = self.previousSibling.x + self.previousSibling.width + #' '
        else
            self.x = self.parent.x
        end
    end

    local superPaint = self.paint
    function self.paint(displayList)
        local text
        if self.node.type == 'input' then
            text = self.node.props.value or ''
        elseif self.node.type == 'button' then
            local child = self.node.props.children[1]
            text = child and child.text or ''

            -- TODO: add more input types
        end

        superPaint(displayList)
        table.insert(displayList, function()
            gpu.set(self.x, self.y, text)
        end)
    end

    function self.print(printList, indent)
        local color = self.node.props.style.color or
            self.parent and self.parent.node.props.style.color or
            0xFFFFFF
        table.insert(
            printList,
            string.rep(' ', indent) ..
            (string.gsub(
                tostring(self.node.type),
                '^%l',
                string.upper)
            ) ..
            '( ' .. self.x .. ', ' .. self.y .. '): ' .. color
        )
    end

    return self
end

return InputLayout
