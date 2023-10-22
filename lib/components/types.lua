---@meta Browser

---@alias nodeType any

---@alias positionalAlignment
---| 'center'
---| 'flex-end'
---| 'flex-start'

---@alias distributedAlignment
---| 'space-around'
---| 'space-between'
---| 'space-evenly'
---| 'stretch'

---@alias alignOptions
---| 'auto'
---| 'baseline'
---| positionalAlignment

---@alias justifyOptions
---| 'normal'
---| distributedAlignment
---| positionalAlignment

---@alias displayOptions
---| 'block'
---| 'flex'
---| 'grid'
---| 'inherit'
---| 'inline-block'
---| 'inline'
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
---@field border? Box | boolean
---@field color? integer
---@field display? displayOptions
---@field flex? { [1]: integer }
---@field flexdirection? 'row' | 'column'
---@field gap? integer
---@field height? integer
---@field justifycontent? justifyOptions
---@field margin? Box
---@field padding? Box
---@field visible? boolean
---@field width? integer

---@alias text string | number

---@class Component
---@field [1] text | function | Component tag or child
---@field [number]? text | Component child
---@field [string] any attribute

---@class Props
---@field children Component[]
---@field style Style
---@field type? nodeType | string
---@field value text | function | Component

---@class Node
---@field props { children: Node[], style: Style }
---@field type nodeType
---@field value? text | function | Component

---@class LayoutObject
---@field backgroundcolor integer
---@field border Box | boolean
---@field children LayoutObject[]
---@field color integer
---@field height integer
---@field margin Box
---@field padding Box
---@field text? string
---@field width integer
---@field x integer
---@field y integer

---@class PaintObject
---@field backgroundcolor integer
---@field color integer
---@field height integer
---@field type string
---@field value string
---@field vertical boolean
---@field width integer
---@field x integer
---@field y integer
