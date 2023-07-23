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
    local propsStyle = props.style or {}
    local propsMargin = propsStyle.margin or {}
    local propsPadding = propsStyle.padding or {}

    local margin = {
        top = propsMargin.top or propsMargin[1] or 0,
        right = propsMargin.right or propsMargin[2] or propsMargin[1] or 0,
        bottom = propsMargin.bottom or propsMargin[3] or propsMargin[1] or 0,
        left = propsMargin.left
            or propsMargin[4]
            or propsMargin[2]
            or propsMargin[1]
            or 0,
    }

    local padding = {
        top = propsPadding.top or propsPadding[1] or 0,
        right = propsPadding.right or propsPadding[2] or propsPadding[1] or 0,
        bottom = propsPadding.bottom or propsPadding[3] or propsPadding[1] or 0,
        left = propsPadding.left
            or propsPadding[4]
            or propsPadding[2]
            or propsPadding[1]
            or 0,
    }

    local style = merge(
        default.block.style,
        propsStyle,
        { padding = padding, margin = margin }
    )

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
