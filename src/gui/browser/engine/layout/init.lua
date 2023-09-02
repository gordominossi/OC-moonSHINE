---@type Layout
local Layout = {}

local emptyBox = { top = 0, right = 0, bottom = 0, left = 0 }

---@return Layout
function Layout.new()
  ---@class Layout
  local self = {}

  ---@param node Node
  ---@param parent LayoutObject?
  ---@param parentNode Node?
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
    if parentNode and parentNode.props.style.display == 'flex' then
      return self.flex(
        node,
        parent,
        parentNode,
        previousSibling
      )
    end

    return self.normal(
      node,
      parent,
      parentNode,
      previousSibling,
      previousNode
    )
  end

  ---@param node Node
  ---@param parent LayoutObject?
  ---@param parentNode Node?
  ---@param previousSibling LayoutObject?
  ---@return LayoutObject
  function self.flex(node, parent, parentNode, previousSibling)
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
      if parentStyle.flexdirection == 'row' then
        y = previousSibling.y + previousSibling.height
      else
        x = previousSibling.x + previousSibling.width
      end
    end

    local flexTotal = 0
    for _, child in ipairs(parentNode and parentNode.props.children or {}) do
      flexTotal = flexTotal + (child.props.style.flex or { 0 })[1]
    end

    local width = (style.flex and style.flex[1] == 1)
        and ((parent.width or parentStyle.width or 160)
          * (style.flex or { 0 })[1]
          / flexTotal)
        or style.width
    local height = parent.height
    local children = {}
    local layoutObject = {
      children = children,
      width = width,
      height = height,
      x = x,
      y = y,
      color = style.color,
      backgroundcolor = style.backgroundcolor,
    }

    local childrenHeight = 0
    local childrenWidth = 0
    for i, child in ipairs(node.props.children) do
      local layoutChild = self.execute(
        child,
        layoutObject,
        node,
        layoutObject.children[i - 1]
      )

      if parentStyle.flexdirection == 'row' then
        layoutChild.width = layoutObject.width
      else
        layoutChild.height = layoutObject.height
      end

      local childMargin = child.props.style.margin
      local childHeight = layoutChild.height
          + childMargin.top
          + childMargin.bottom
      local childWidth = layoutChild.width
          + childMargin.right
          + childMargin.left

      if parentStyle.flexdirection == 'row' then
        childrenHeight = math.max(childrenHeight, childHeight)
        childrenWidth = childrenWidth + childWidth
      else
        childrenWidth = math.max(childrenWidth, childWidth)
        childrenHeight = childrenHeight + childHeight
      end

      layoutObject.children[i] = layoutChild
    end

    layoutObject.width = childrenWidth
    layoutObject.height = childrenHeight

    return layoutObject
  end

  ---@param node Node
  ---@param parent LayoutObject?
  ---@param parentNode Node?
  ---@param previousSibling LayoutObject?
  ---@param previousNode Node?
  ---@return LayoutObject
  function self.normal(
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

    local maxWidth = parent.width
        and (parent.width
          - (margin.left + margin.right)
          - (parentBorder.left + parentBorder.right)
          - (parentPadding.left + parentPadding.right))
        or (parentStyle.display ~= 'flex'
          and style.display == 'block'
          and 160)
    local width = style.width or maxWidth or 160
    local height = style.height or
        (style.padding.top
          + style.padding.bottom
          + style.border.top
          + style.border.bottom)
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

      if style.display == 'flex'
          and style.flexdirection ~= 'row'
          and child.props.style.flex
          and child.props.style.flex[1]
      then
        local flexTotal = 0
        for _, flexChild in ipairs(node.props.children or {}) do
          flexTotal = flexTotal + (flexChild.props.style.flex or { 0 })[1]
        end
        layoutChild.width = width * (child.props.style.flex or { 0 })[1] / flexTotal
      end

      local notEnoughWidth = style.display == 'inline'
          and layoutChild.x + layoutChild.width > (width or 160)
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
