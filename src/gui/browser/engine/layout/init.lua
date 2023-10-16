local traverseBreadthFirst = require('lib.language-extensions').traverseBreadthFirst

local Layout = {}

local Flex = require('src.gui.browser.engine.layout.flex')
local Normal = require('src.gui.browser.engine.layout.normal')

---@param box LayoutObject
---@return integer
local function getHeight(box)
  if box.text then
    return 1
  end

  local maxChildHeight = box.height
  for _, child in ipairs(box.children) do
    maxChildHeight = math.max(
      maxChildHeight,
      child.y
      + child.height
      + child.margin.bottom
    )
  end

  if #box.children > 0 then
    return maxChildHeight
        - box.y
        + box.border.bottom
  end

  return box.height
      or box.padding.top
      + box.padding.bottom
      + box.border.top
      + box.border.bottom
end

function Layout.new()
  local self = {}

  ---@param node Node
  ---@return LayoutObject
  function self.execute(node)
    local stack = { {
      node = node,
      layout = node.props.style.display == 'flex'
          and Flex.execute(node)
          or Normal.execute(node),
    } }

    local parent = stack[#stack]
    while #stack > 0 do
      parent = stack[#stack] or parent
      local parentLayout = parent.layout
      local parentNode = parent.node
      local nodeChildCount = #parentNode.props.children
      local layoutChildCount = #parentLayout.children

      if nodeChildCount > layoutChildCount then
        local childLayoutType = parentNode.props.style.display == 'flex'
            and Flex
            or Normal

        local childNode = parentNode.props.children[layoutChildCount + 1]
        local previousSibling = parentLayout.children[layoutChildCount]
        local previousNode = parentNode.props.children[layoutChildCount]

        local childLayout = childLayoutType.execute(
          childNode,
          parentLayout,
          parentNode,
          previousSibling,
          previousNode
        )
        childLayout.height = getHeight(childLayout)

        table.insert(stack, {
          node = childNode,
          layout = childLayout,
        })
        table.insert(parentLayout.children, childLayout)

        parentLayout.height = getHeight(parentLayout)
      else
        table.remove(stack)

        parentLayout.height = getHeight(parentLayout)
      end
    end

    return parent.layout
  end

  return self
end

return Layout
