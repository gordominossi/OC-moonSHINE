local gpu = require('component').gpu

local BaseLayout = require('src.gui.browser.engine.layout.base')
local BlockLayout = require('src.gui.browser.engine.layout.block')

local DocumentLayout = {}
---@param node Element
---@return DocumentLayout
function DocumentLayout.new(node)
    ---@class DocumentLayout : Layout
    ---@field node Element
    local self = BaseLayout.new(node)

    function self.layout()
        local child = BlockLayout.new(self.node, self)
        table.insert(self.children, child)

        local resolution = {}
        resolution.width = gpu.getResolution()

        self.width = self.node.props.style.width or resolution.width
        self.x = 0
        self.y = self.node.props.y or 0
        child.layout()
        self.x = self.node.props.x or 1
        self.height = child.height
    end

    function self.print(printList, indent)
        indent = indent or 0
        table.insert(
            printList,
            string.rep(' ', indent) ..
            'Document(' ..
            self.x ..
            ' ' ..
            self.y ..
            '): '
        )
        self.children[1].print(printList, indent + 2)
    end

    return self
end

return DocumentLayout
