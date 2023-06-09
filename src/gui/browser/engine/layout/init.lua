---@type Layout
local Layout = {}

---@return Layout
function Layout.new()
    ---@class Layout
    local self = {}

    ---@class LayoutObject
    ---@field children LayoutObject[]
    ---@field height integer
    ---@field width integer
    ---@field x integer
    ---@field y integer
    ---@field node Node
    ---@field parent LayoutObject
    ---@field previous LayoutObject
    ---@field style Style

    ---comment
    ---@param node Node
    ---@param parent LayoutObject?
    ---@param previousSibling LayoutObject?
    ---@return table
    function self.execute(node, parent, previousSibling)
        parent = parent or {}
        previousSibling = previousSibling or {}
        local style = node.props.style or parent.style or {}
        local layoutObject = {
            node = node,
            parent = parent,
            previous = previousSibling,
            children = {},
            width = parent.width or style.width or 0,
            height = parent.height or style.height or 0,
            x = (parent.x or 0) + (previousSibling.x or 0),
            y = parent.y or 0,
            style = style,
        }

        if (node.type == 'text') then
            layoutObject.height = 1
            layoutObject.width = #node.value
        end

        for i, child in ipairs(node.props.children) do
            layoutObject.children[i] = self.execute(child, layoutObject, layoutObject.children[i - 1])
            layoutObject.height = layoutObject.height + layoutObject.children[i].height
        end

        return layoutObject
    end

    return self
end

return Layout
