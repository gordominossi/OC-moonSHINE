local merge = require('lib.language-extensions').mergeTables

---@type Node
local Node = {}

---@param type string
---@param props? NodeProps
---@param children? Node[]
---@return Node
function Node.new(type, props, children)
    props = props or {}
    ---@type Style
    local style = merge(
        { color = 0xFFFFFF, display = 'block' },
        props.style or {}
    )

    ---@type NodeProps
    local _props = merge(
        { children = children or {} },
        props,
        { style = style }
    )
    _props.type = nil
    for i = 1, #_props do
        _props[i] = nil
    end

    local _key, _value
    _key, _props.key = _props.key, nil
    _value, _props.value = _props.value, nil

    ---@class Node
    local self = {
        type = type,
        key = _key,
        value = _value,
        props = _props,
    }

    return self
end

return Node
