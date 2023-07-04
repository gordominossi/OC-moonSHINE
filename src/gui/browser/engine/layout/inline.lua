local BaseLayout = require('src.gui.browser.engine.layout.base')
local LineLayout = require('src.gui.browser.engine.layout.line')
local TextLayout = require('src.gui.browser.engine.layout.text')
local InputLayout = require('src.gui.browser.engine.layout.input')

local InlineLayout = {}
---@param node Element
---@param parent Layout
---@param previousSibling? Layout
---@return InlineLayout
function InlineLayout.new(node, parent, previousSibling)
    ---@class InlineLayout : Layout
    ---@field node Element
    local self = BaseLayout.new(node, parent, previousSibling)

    function self.layout()
        self.x = (self.node.props.x or 0) + self.parent.x
        self.width = self.node.props.style.width or self.parent.width or 0
        self.width = math.min(
            self.width,
            math.abs((self.node.props.x or 0) - self.parent.width)
        )

        if self.previousSibling then
            self.y = self.previousSibling.y + self.previousSibling.height
        else
            self.y = (self.node.props.x or 0) + self.parent.y
        end

        self.newLine()
        self.recurse(self.node)

        self.height = (self.node.props.x or 0)
        for _, line in ipairs(self.children) do
            line.layout()
            self.height = self.height + line.height
        end
        self.height = self.node.props.style.height or self.height
    end

    ---@param n Node
    function self.recurse(n)
        ---@cast n Text
        if n.text then
            self.text(n)
        else
            ---@cast n Element
            if n.type == 'br' then
                self.newLine()
            elseif n.type == 'input' or n.type == 'button' then
                self.input(n)
            else
                for _, child in ipairs(n.props.children) do
                    self.recurse(child)
                end
            end
        end
    end

    function self.newLine()
        self.previousWord = nil
        self.xOffset = self.x
        local lastLine = self.children[#self.children]
        local newLine = LineLayout.new(self.node, self, lastLine)
        table.insert(self.children, newLine)
    end

    ---@param n Text
    function self.text(n)
        for word in string.gmatch(n.text, '%S+') do
            if self.xOffset + #word > self.x + self.width then
                self.newLine()
            end
            local line = self.children[#self.children]
            local text = TextLayout.new(n, word, line, self.previousWord)
            table.insert(line.children, text)
            self.previousWord = text
            self.xOffset = self.xOffset + #(word .. ' ')
        end
    end

    ---@param n Element
    function self.input(n)
        local line = self.children[#self.children]
        local input = InputLayout.new(n, line, self.previousWord)
        table.insert(line.children, input)
        self.previousWord = input
        self.xOffset = self.xOffset + (n.props.length or 0) + #' '
    end

    function self.print(printList, indent)
        table.insert(printList, string.rep(' ', indent) .. 'Inline(' .. self.x .. ' ' .. self.y .. '):')
        for _, child in ipairs(self.children) do
            child.print(printList, indent + 2)
        end
    end

    return self
end

return InlineLayout
