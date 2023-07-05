local colors = require('lib.colors')
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
    local style = merge(default.block.style,props.style or {})

    ---@type Props
    local _props = merge(
        { children = children or {} },
        props,
        { style = style }
    )
    _props.type = nil
    for i = 1, #_props do
        _props[i] = nil
    end

    local _value
    _value, _props.value = _props.value, nil

    ---@type Node
    local self = {
        type = type,
        value = _value,
        props = _props,
    }

    return self
end

return Node
