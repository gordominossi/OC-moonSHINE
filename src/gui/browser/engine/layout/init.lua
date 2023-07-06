---@type Layout
local Layout = {}

function Standardize(property)
    if property == { 0 } then
        property = { top = 0, left = 0, right = 0, bottom = 0 }
    else
        property = {
            top = property[1],
            left = property[2] or property[1],
            right = property[3] or
                property[2] or
                property[1],
            bottom = property[4] or property[1],
        }
    end
    return property
end

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
        previousSibling = previousSibling or {}

        local parentNode = parent.node or {}
        local parentProps = parentNode.props or {}
        local parentPadding = parentProps.padding or { 0 }
        if #parentPadding ~= 4 then
            parentPadding = Standardize(parentPadding)
        end

        local props = node.props or {}
        local margin = props.margin or { 0 }
        if #margin ~= 4 then margin = Standardize(margin) end

        local positionOffSet = {
            x = (margin.left),
            y = (margin.top),
        }
        if previousSibling.x == nil then
            positionOffSet.x = positionOffSet.x + (parent.x or 0) + (parentPadding.left)
            positionOffSet.y = positionOffSet.y + (parent.y or 0) + (parentPadding.top)
        else
            positionOffSet.x = positionOffSet.x + (previousSibling.x or 0)
            positionOffSet.y = positionOffSet.y + (previousSibling.y or 0) + 1
        end

        local maxWidth = (parent.width or 0) -
            (margin.left + margin.right) -
            (parentPadding.left + parentPadding.right)

        local style = node.props.style or {}
        local layoutObject = {
            node = node,
            parent = parent,
            previous = previousSibling,
            children = {},
            width = props.width or maxWidth,
            height = props.height or parent.height or 0,
            x = positionOffSet.x,
            y = positionOffSet.y,
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
