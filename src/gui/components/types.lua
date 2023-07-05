---@meta

---@alias nodeType
---| 'text'
---| 'div'
---| 'button'

---@alias alignOptions
---| 'auto'
---| 'stretch'
---| 'center'
---| 'flvish ex-start'
---| 'flex-end'
---| 'baseline'
---| 'inherit'

---@alias layoutOptions
---| 'inline'
---| 'block'
---| 'inline-block'
---| 'flex'
---| 'grid'
---| 'inherit'
---| 'none'

---@class Style
---@field aligncontent? alignOptions
---@field alignitems? alignOptions
---@field alignself? alignOptions
---@field backgroundcolor? integer
---@field border? boolean
---@field color? integer
---@field flexdirection? 'row' | 'column'
---@field layout? layoutOptions
---@field margin? table
---@field padding? table
---@field visible? boolean

---@alias text string | number

---@class Component : table
---@field [1] text | function | Component tag or child
---@field style? Style
---@field key? string
---@field [string] any attribute
---@field [number]? text | Component child

---if positive, is relative to the start of the parent Component if negative, is relative to the end of the parent Component
---@class Coordinate2D
---@field x number
---@field y number

---@class Props
---@field children Component[]
---@field width integer
---@field height integer
---@field style Style

---@class NodeProps : table
---@field children Node[]
---@field key any
---@field value any
---@field type string
---@field style Style

---@class Node
---@field type nodeType
---@field value? string
---@field props NodeProps