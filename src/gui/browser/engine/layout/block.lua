local BaseLayout = require('src.gui.browser.engine.layout.base')
local InlineLayout = require('src.gui.browser.engine.layout.inline')

local blockElements = {
    'address',
    'article',
    'aside',
    'blockquote',
    'body',
    'dd',
    'details',
    'div',
    'dl',
    'dt',
    'fieldset',
    'figcaption',
    'figure',
    'footer',
    'form',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'header',
    'hgroup',
    'hr',
    'html',
    'legend',
    'li',
    'main',
    'menu',
    'nav',
    'ol',
    'p',
    'pre',
    'section',
    'summary',
    'table',
    'ul',
}

local function getLayoutMode(node)
    if node.props.style and node.props.style.layout then
        return node.props.style.layout
    end

    if node.text or node.type == 'text' or node.type == 'input' then
        return 'inline'
    end

    for _, child in ipairs(node.props.children) do
        if not child.text and child.type ~= 'text' then
            for _, blockElement in ipairs(blockElements) do
                if child.type == blockElement then
                    return 'block'
                end
            end
        end
    end

    if node.children and #node.children > 0 then
        return 'inline'
    end

    return 'block'
end

local BlockLayout = {}
---@param node Element
---@param parent Layout
---@param previousSibling? Layout
---@return BlockLayout
function BlockLayout.new(node, parent, previousSibling)
    ---@class BlockLayout : Layout
    ---@field node Element
    local self = BaseLayout.new(node, parent, previousSibling)

    function self.layout()
        local previous = nil
        for _, child in ipairs(self.node.props.children) do
            local next
            if getLayoutMode(child) == 'inline' then
                next = InlineLayout.new(child, self, previous)
            else
                next = BlockLayout.new(child, self, previous)
            end
            table.insert(self.children, next)
            previous = next
        end

        self.x = (self.node.props.x or 0) + self.parent.x
        self.width = self.node.props.style.width or self.parent.width or 0
        self.width = math.min(
            self.width,
            math.abs((self.node.props.x or 0) - (self.parent.width or 0))
        )

        if self.previousSibling then
            self.y = self.previousSibling.y + self.previousSibling.height
        else
            self.y = self.parent.y
        end

        self.height = self.node.props.x or 0
        for _, child in ipairs(self.children) do
            child.layout()
            self.height = self.height + child.height
        end
        self.height = self.node.props.style.height or self.height
    end

    function self.print(printList, indent)
        table.insert(
            printList,
            string.rep(' ', indent) ..
            'Block(' ..
            self.x ..
            ' ' ..
            self.y ..
            '): '
        )
        for _, child in ipairs(self.children) do
            child.print(printList, indent + 2)
        end
    end

    return self
end

return BlockLayout
