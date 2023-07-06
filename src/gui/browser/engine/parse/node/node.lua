local default = require('lib.default-components')
local merge = require('lib.language-extensions').mergeTables

---@type Node
local Node = {}

---@param type string
---@param props? Props
---@param children? Node[]
---@return Node
function Node.new(type, props, children)
    props = props or {}
    ---@type Style
    local style = merge(default.block.style, props.style)

    ---@type Props
    local nodeProps = merge(
        { children = children or {} },
        props,
        { style = style }
    )
    nodeProps.type = nil
    for i = 1, #nodeProps do
        nodeProps[i] = nil
    end

    local value
    value, nodeProps.value = nodeProps.value, nil

    ---@type Node
    local self = {
        type = type,
        value = value,
        props = nodeProps,
    }

    return self
end

return Node
