local gpu = require('component').gpu

local BaseLayout = require('src.gui.browser.engine.layout.base')

---@type TextLayout
local TextLayout = {}
---@param node Text
---@param parent Layout
---@param previousSibling? Layout
---@return TextLayout
function TextLayout.new(node, word, parent, previousSibling)
    ---@class TextLayout : Layout
    local self = BaseLayout.new(node, parent, previousSibling)
    self.word = word

    function self.layout()
        self.width = #self.word
        if self.previousSibling then
            self.x = self.previousSibling.x + self.previousSibling.width + #' '
        else
            self.x = self.parent.x
        end

        self.height = 1
    end

    local superPaint = self.paint
    function self.paint(displayList)
        superPaint(displayList)
        table.insert(displayList, function()
            gpu.set(self.x, self.y, self.word)
        end)
    end

    function self.print(printList, indent)
        local color = self.node.props.style.color or
            self.parent and self.parent.node.props.style.color or
            0xFFFFFF
        table.insert(
            printList,
            string.rep(' ', indent) ..
            'Text(' ..
            self.x ..
            ', ' ..
            self.y ..
            '): ' ..
            color ..
            ' ' ..
            self.word
        )
    end

    return self
end

return TextLayout
