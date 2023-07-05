
local colors = require('lib.colors')
local merge = require('lib.language-extensions').mergeTables

---@type Style
local defaulStyle = {
    aligncontent = 'auto',
    alignitems = 'auto',
    alignself = 'auto',
    backgroundcolor = colors.background,
    border = false,
    color = colors.default,
    flexdirection = 'column',
    layout = 'inline',
    margin = {0},
    padding = {0},
    visible = true,
}



local defaultLayout = {
    text = {
        style = defaulStyle},
    block = {
        style = merge(defaulStyle,{display='block'})},
}

return defaultLayout
