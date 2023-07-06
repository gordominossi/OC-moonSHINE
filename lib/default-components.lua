local colors = require('lib.colors')
local merge = require('lib.language-extensions').mergeTables

---@type Style
local defaultStyle = {
    aligncontent = 'auto',
    alignitems = 'auto',
    alignself = 'auto',
    backgroundcolor = colors.background,
    border = false,
    color = colors.default,
    flexdirection = 'column',
    display = 'inline',
    margin = { 0 },
    padding = { 0 },
    visible = true,
}

local defaultLayout = {
    text = { style = defaultStyle },
    block = { style = merge(defaultStyle, { display = 'block' }) },
}

return defaultLayout
