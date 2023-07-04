local progressBar = require('src.gui.components.atoms.progress-bar')
local container = require('src.gui.components.atoms.container')
local list = require('src.gui.components.molecules.list')

---@enum AltarIconSizes
local altarIconSizes = {
    large = 'large',
    small = 'small',
}

---@param props { size: AltarIconSizes }
---@return Component
local altarIcon = function(props)
    local component = ({
        [altarIconSizes.large] = {
            '        ⋰  ⋱        ',
            '      ⋰      ⋱      ',
            '      ⋱      ⋰      ',
            '  ⋰  ⋱  ⋱  ⋰  ⋰  ⋱  ',
            '⋰      ⋱    ⋰      ⋱',
            '⋱      ⋰    ⋱      ⋰',
            '  ⋱  ⋰  ⋰  ⋱  ⋱  ⋰  ',
            '      ⋰      ⋱      ',
            '      ⋱      ⋰      ',
            '        ⋱  ⋰        '
        },
        [altarIconSizes.small] = {
            '  ⋰ ⋱   ',
            '⋰ ⋱ ⋰ ⋱ ',
            '⋱ ⋰ ⋱ ⋰ ',
            '  ⋱ ⋰   ',
        },
    })[props.size]

    return component
end


---@param props AltarModel
---@return Component
local function altarComponent(props)
    ---@type Component[]
    local evenBars, oddBars = {}, {}
    for index, progress in ipairs(props.progressBars) do
        if index % 2 == 0 then
            table.insert(evenBars, {
                progressBar,
                progress = progress
            })
        else
            table.insert(oddBars, {
                progressBar,
                progress = progress
            })
        end
    end

    ---@type Component
    local component = {
        container,
        title = props.message or 'No altar',
        style = {
            display = 'inline-block',
            padding = 1,
            border = 1,
        },
        {
            altarIcon,
            size = #props.progressBars > 0 and
                altarIconSizes.large or
                altarIconSizes.small,
            style = { margin = 1 },
        },
        {
            list,
            style = { margin = 4 },
            table.unpack(evenBars),
        },
        {
            list,
            style = { margin = 4 },
            table.unpack(oddBars),
        }
    }

    return component
end

---@class AltarModel
---@field altarId string
---@field message? string
---@field progressBars Progress[]

---@param props AltarModel[]
---@return Component
local function viewComponent(props)
    ---@type Component[]
    local altarRows = {}
    for index = 1, math.ceil(#props / 2) do
        altarRows[index] = {
            container,
            style = { direction = 'row' },
            {
                altarComponent,
                table.unpack(props[2 * index - 1])
            },
            {
                altarComponent,
                table.unpack(props[2 * index] or { progressBars = {} })
            },
        }
    end

    local component = {
        container,
        title = 'Infusion automation',
        style = {
            paddingTop = 6,
            paddingRigth = 1,
            paddingLeft = 1,
            border = 1,
        },
        table.unpack(altarRows)
    }

    return component
end


return viewComponent
