---@meta

---@alias nodeType any

---@alias alignOptions
---| 'auto'
---| 'stretch'
---| 'center'
---| 'flvish ex-start'
---| 'flex-end'
---| 'baseline'
---| 'inherit'

---@alias displayOptions
---| 'inline'
---| 'block'
---| 'inline-block'
---| 'flex'
---| 'grid'
---| 'inherit'
---| 'none'

---@alias Box
---| { top: integer, right: integer, bottom: integer, left: integer }
---| { [1]: integer }
---| { [2]: integer }
---| { [3]: integer }
---| { [4]: integer }

---@class Style
---@field aligncontent? alignOptions
---@field alignitems? alignOptions
---@field alignself? alignOptions
---@field backgroundcolor? integer
---@field color? integer
---@field display? displayOptions
---@field flex? { [1]: integer }
---@field flexdirection? 'row' | 'column'
---@field gap? integer
---@field margin? Box
---@field padding? Box
---@field border? Box | boolean
---@field width? integer
---@field height? integer
---@field visible? boolean

---@alias text string | number

---@class Component : table
---@field [1] text | function | Component tag or child
---@field [string] any attribute
---@field [number]? text | Component child

---if positive, is relative to the start of the parent Component if negative, is relative to the end of the parent Component
---@class Coordinate2D
---@field x number
---@field y number

---@class Attributes
---@field border? boolean
---@field display? displayOptions
---@field flexdirection? 'row' | 'column'
---@field visible? boolean

---@class Props
---@field children Component[]
---@field attributes Attributes
---@field style Style
---@field type? nodeType | string

---@class Node
---@field type nodeType
---@field value? string | number | function | Component
---@field props Props

---@class LayoutObject
---@field children LayoutObject[]
---@field height integer
---@field width integer
---@field x integer
---@field y integer
---@field color integer
---@field backgroundcolor integer
---@field border Box | boolean
---@field text? string

---@class PaintObject
---@field type string
---@field x integer
---@field y integer
---@field height integer
---@field width integer
---@field value string
---@field vertical boolean
---@field color integer
---@field backgroundcolor integer
