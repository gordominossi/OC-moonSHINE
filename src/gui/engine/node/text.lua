local merge = require('lib.language-extensions').mergeTables

local Node = require('src.gui.engine.node.node')

---@type Text
local Text = {}
---@param props? NodeProps
---@return Text
function Text.new(props)
    props = props or {}
    local _style = merge(
        props.style or {},
        { display = 'inline' }
    )
    local _props = merge(props, { style = _style })

    ---@class Text : Node
    local self = Node.new('text', _props)

    return self
end

return Text