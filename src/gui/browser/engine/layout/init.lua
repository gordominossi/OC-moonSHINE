---@type Layout
local Layout = {}

local emptyBox = { top = 0, right = 0, bottom = 0, left = 0 }

---@return Layout
function Layout.new()
    ---@class Layout
    local self = {}

    ---@param node Node
    ---@param parent LayoutObject?
    ---@param previousSibling LayoutObject?
    ---@param previousNode Node?
    ---@return LayoutObject
    function self.execute(
        node,
        parent,
        parentNode,
        previousSibling,
        previousNode
    )
        parent = parent or {}
        local parentStyle = parentNode and parentNode.props.style or {}
        local parentPadding = parentStyle.padding or emptyBox
        local parentBorder = parentStyle.border or emptyBox

        local style = node.props.style
        local margin = style.margin or emptyBox

        local x = (parent.x or 0)
            + parentBorder.left
            + parentPadding.left
            + margin.left
        local y = (parent.y or 0)
            + parentBorder.top
            + parentPadding.top
            + margin.top

        if previousSibling then
            local previousMargin = previousNode
                and previousNode.props.style.margin
                or emptyBox
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
        local width = style.width or maxWidth
        local height = style.padding.top
                + style.padding.bottom
                + style.border.top
            + style.border.bottom
        if (node.type == 'text') then
            width = #node.value
            height = 1
        end

        local layoutObject = {
            children = {},
            width = width,
            height = height,
            x = x,
            y = y,
            color = style.color,
            backgroundcolor = style.backgroundcolor,
        }

        local childrenHeight = 0
        for i, child in ipairs(node.props.children) do
            local layoutChild = self.execute(
                child,
                layoutObject,
                node,
                layoutObject.children[i - 1],
                node.props.children[i - 1]
            )

            local notEnoughWidth = style.display == 'inline'
                and layoutChild.x + layoutChild.width > width
            if notEnoughWidth then
                layoutChild.x = x
                    + style.padding.left
                    + child.props.style.margin.left
                layoutChild.y = y + style.padding.top + childrenHeight
            end

            if childrenHeight == 0
                or style.display == 'block'
                or notEnoughWidth
            then
                childrenHeight = childrenHeight
                    + layoutChild.height
                    + child.props.style.margin.top
                    + child.props.style.margin.bottom
            end

            layoutObject.children[i] = layoutChild
        end

        layoutObject.height = style.height
            or (layoutObject.height + childrenHeight)

        return layoutObject
    end

    return self
end

return Layout
