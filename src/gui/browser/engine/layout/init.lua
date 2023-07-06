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
        local parentStyle = parent.style or {}
        local parentPadding = parentStyle.padding or {}
        previousSibling = previousSibling or {}
        local props = node.props or {}
        local style = node.props.style or {}

        local margin = {
            top = style.margin[1] or 0,
            left = style.margin[2] or style.margin[1] or 0,
            right = style.margin[3] or style.margin[2] or style.margin[1] or 0,
            bottom = style.margin[4] or style.margin[1] or 0,
        }

        local parentPadding = {
            top = parentPadding[1] or 0,
            left = parentPadding[2] or parentPadding[1] or 0,
            right = parentPadding[3] or
                    parentPadding[2] or
                    parentPadding[1] or 0,
            bottom = parentPadding[4] or parentPadding[1] or 0,
        }

        local maxWidth = (parent.width or 0) -
                         (margin.left + margin.right) -
                         (parentPadding.left + parentPadding.right)

        local positionOffSet = {
            x = (parent.x or 0) +
                (margin.left) +
                (parentPadding.left),
            y = (parent.y or 0) +
                (margin.top) +
                (parentPadding.top) +
                (previousSibling.y or 0),
        }

        if previousSibling.y==positionOffSet.y then
            positionOffSet.y=positionOffSet.y+1
        end

        local layoutObject = {
            node = node,
            parent = parent,
            previous = previousSibling,
            children = {},
            width = props.width or maxWidth,
            height = props.height or parent.height or 0,
            x = positionOffSet.x,
            y = positionOffSet.y,
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
