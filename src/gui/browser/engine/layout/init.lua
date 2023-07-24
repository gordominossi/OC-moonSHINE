---@type Layout
local Layout = {}

---@return Layout
function Layout.new()
    ---@class Layout
    local self = {}

    ---@param node Node
    ---@param parent LayoutObject?
    ---@param previousSibling LayoutObject?
    ---@return LayoutObject
    function self.execute(node, parent, previousSibling)
        parent = parent or {}
        local parentStyle = parent.node and parent.node.props.style or {}
        local parentPadding = parentStyle.padding
            or { top = 0, right = 0, bottom = 0, left = 0 }
        local parentBorder = parentStyle.border
            or { top = 0, right = 0, bottom = 0, left = 0 }
        local style = node.props.style
        local margin = style.margin

        local x = (parent.x or 0)
            + parentBorder.top
            + parentPadding.left
            + margin.left
        local y = (parent.y or 0)
            + parentBorder.top
            + parentPadding.top
            + margin.top

        if previousSibling then
            local previousMargin = previousSibling.node.props.style.margin
            if parentStyle.display == 'inline' then
                x = previousSibling.x
                    + previousSibling.width
                    + #' '
                    + math.max(
                        previousMargin.right,
                        margin.left
                    )
            else
                y = previousSibling.y
                    + previousSibling.height
                    + math.max(
                        previousMargin.bottom,
                        margin.top
                    )
            end
        end

        local maxWidth = (parent.width or 160)
            - (margin.left + margin.right)
            - (parentBorder.left + parentBorder.right)
            - (parentPadding.left + parentPadding.right)

        local layoutObject = {
            node = node,
            parent = parent,
            previous = previousSibling or {},
            children = {},
            width = style.width or maxWidth,
            height = style.padding.top
                + style.padding.bottom
                + style.border.top
                + style.border.bottom,
            x = x,
            y = y,
            color = style.color,
            backgroundcolor = style.backgroundcolor,
        }

        if (node.type == 'text') then
            layoutObject.width = #node.value
        end

        for i, child in ipairs(node.props.children) do
            layoutObject.children[i] = self.execute(
                child,
                layoutObject,
                layoutObject.children[i - 1]
            )
            if style.display ~= 'inline' then
                layoutObject.height = layoutObject.height
                    + layoutObject.children[i].height
                    + child.props.style.margin.top
                    + child.props.style.margin.bottom
            end
        end

        if style.display == 'inline' then
            layoutObject.height = layoutObject.height + 1
        end

        layoutObject.height = style.height or layoutObject.height

        return layoutObject
    end

    return self
end

return Layout
