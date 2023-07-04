local BaseLayout = require('src.gui.browser.engine.layout.base')

local LineLayout = {}
---@param node Element
---@param parent Layout
---@param previousSibling? Layout
---@return LineLayout
function LineLayout.new(node, parent, previousSibling)
    ---@class LineLayout : Layout
    local self = BaseLayout.new(node, parent, previousSibling)

    function self.layout()
        self.width = self.parent.width
        self.x = self.parent.x

        if self.previousSibling then
            self.y = self.previousSibling.y + self.previousSibling.height
        else
            self.y = self.parent.y
        end


        if #self.children == 0 then
            self.height = 0
            return
        end

        for _, word in ipairs(self.children) do
            word.layout()
            word.y = self.y + 1
        end

        self.height = 1
    end

    function self.print(printList, indent)
        table.insert(printList, string.rep(' ', indent) .. 'Line(' .. self.x .. ' ' .. self.y .. '):')
        for _, child in ipairs(self.children) do
            child.print(printList, indent + 2)
        end
    end

    return self
end

return LineLayout
