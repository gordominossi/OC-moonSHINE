---@type Layout
local Layout = {}

---@return Layout
function Layout.new()
    ---@class Layout
    local self = {}

    ---comment
    ---@param node Node
    ---@param parent LayoutObject?
    ---@param previousSibling LayoutObject?
    ---@return table
    function self.execute(node, parent, previousSibling)
        parent = parent or {}
        local parentStyle = parent.node and parent.node.props.style or {}
        local parentPadding = parentStyle.padding or
            { top = 0, right = 0, bottom = 0, left = 0 }

        local props = node.props
        local style = node.props.style
        local margin = style.margin

        local positionOffset = { x = margin.left, y = margin.top }
        if previousSibling then
            positionOffset.x = positionOffset.x + previousSibling.x
            positionOffset.y = positionOffset.y + previousSibling.y + 1
        else
            positionOffset.x = positionOffset.x +
                (parent.x or 0) +
                parentPadding.left
            positionOffset.y = positionOffset.y +
                (parent.y or 0) +
                parentPadding.top
        end

        local maxWidth = (parent.width or 0) -
            (margin.left + margin.right) -
            (parentPadding.left + parentPadding.right)

        local layoutObject = {
            node = node,
            parent = parent,
            previous = previousSibling or {},
            children = {},
            width = props.width or maxWidth,
            height = props.height or parent.height or 0,
            x = positionOffset.x,
            y = positionOffset.y,
            color = style.color,
            backgroundcolor = style.backgroundcolor,
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
