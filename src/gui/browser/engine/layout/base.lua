local gpu = require('component').gpu

local BaseLayout = {}
---@param node Element | Text
---@param parent? Layout
---@param previousSibling? Layout
---@return Layout2
function BaseLayout.new(node, parent, previousSibling)
    ---@class Layout2
    local self = {
        node = node,
        parent = parent,
        previousSibling = previousSibling,
        children = {},
        x = nil,
        y = nil,
        height = nil,
        width = nil,
        layout = function()
        end,
    }

    function self.paint(displayList)
        self.node.props.style = self.node.props.style or {}
        self.node.props.style.color = self.node.props.style.color or
            self.parent and self.parent.node.props.style.color or
            0xFFFFFF
        table.insert(displayList, function()
            gpu.setForeground(self.node.props.style.color)
        end)
        self.node.props.style.backgroundcolor = self.node.props.style.backgroundcolor or
            self.parent and self.parent.node.props.style.backgroundcolor
            or 0x000000

        table.insert(displayList, function()
            gpu.setBackground(self.node.props.style.backgroundcolor)
        end)
        table.insert(displayList, function()
            if self.node.text then
                gpu.fill(self.x, self.y + 1, self.width, self.height - 1, ' ')
            else
                gpu.fill(self.x, self.y + 1, self.width, self.height, ' ')
            end
        end)
        for _, child in ipairs(self.children) do
            child.paint(displayList)
        end
    end

    return self
end

return BaseLayout
