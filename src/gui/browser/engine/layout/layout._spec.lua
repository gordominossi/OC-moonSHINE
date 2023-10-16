local describe = _ENV.describe
local it = _ENV.it

local colors = require('lib.colors')
local default = require('lib.default-components')
local screenSize = require('lib.screen-sizes')

local Layout = require('src.gui.browser.engine.layout')
local Parser = require('src.gui.browser.engine.parse')

local extensions = require('lib.language-extensions')
local merge = extensions.mergeTables
local traverseBreadthFirst = extensions.traverseBreadthFirst

describe('Layout', function()
  local layout = Layout.new()
  local parser = Parser.new()

  describe('normal flow', function()
    describe('block', function()
      it('Should be layed out one after another, vertically', function()
        local input = parser.execute({ 'div', 'text1', 'text2' })

        local result = layout.execute(input)

        assert.same(result.y, result.children[1].y)
        assert.same(result.y + 1, result.children[2].y)
      end)

      it('Should align its left edge with its parent\'s', function()
        local input = parser.execute({
          'div',
          style = { margin = { left = 3 } },
          'text1',
          'text2',
        })

        local result = layout.execute(input)

        assert.same(result.x, result.children[1].x)
        assert.same(result.x, result.children[2].x)
      end)

      it('Should occupy the whole parent width', function()
        local input = parser.execute({
          'div',
          style = { width = 16 },
          { 'div', 'text1' },
          { 'div', 'text2' },
        })

        local result = layout.execute(input)

        assert.same(result.width, result.children[1].width)
        assert.same(result.width, result.children[2].width)
      end)

      it('Should have just enough height to fit its content', function()
        local input = parser.execute({
          'div',
          { type = 'div', style = { height = 1 } },
          { type = 'div', style = { height = 10 } },
        })

        local result = layout.execute(input)

        assert.same(11, result.height)
      end)

      it('Should have enough height to fit nested content', function()
        local input = parser.execute({ {
          'div',
          { type = 'div', style = { height = 1 } },
          { type = 'div', style = { height = 10 } },
        } })

        local result = layout.execute(input)

        assert.same(11, result.height)
      end)
    end)

    describe('inline', function()
      it('Should ignore width and height', function()
        local input = parser.execute({
          'div',
          style = { width = 2, height = 2, display = 'inline' },
          'text',
        })

        local result = layout.execute(input)

        assert.same(result.children[1].width, #'text')
        assert.same(result.children[1].height, 1)
      end)

      it('Should be layed out on the same line along its siblings', function()
        local input = parser.execute(
          {
            'div',
            style = { display = 'inline' },
            'text1',
            'text2',
          }
        )

        local result = layout.execute(input)

        assert.same(result.x, result.children[1].x)
        assert.same(result.y, result.children[1].y)
        assert.same(result.x + #'text1' + #' ', result.children[2].x)
        assert.same(result.y, result.children[2].y)
      end)

      it(
        'Should break into a new line if parent\'s width is not enough',
        function()
          local input = parser.execute(
            {
              'div',
              style = { display = 'inline', width = #'text1' },
              'text1',
              'text2',
            }
          )

          local result = layout.execute(input)

          assert.same(result.x, result.children[1].x)
          assert.same(result.y, result.children[1].y)
          assert.same(result.x, result.children[2].x)
          assert.same(result.y + 1, result.children[2].y)
        end
      )
    end)

    it('Should collapse margins on the vertical direction', function()
      local input = parser.execute({
        'div',
        {
          'div',
          style = { display = 'inline', margin = 5 },
          'text1',
          'text2',
        },
        { 'div', style = { margin = 2 }, 'text1' },
        {
          'div',
          style = { display = 'inline', width = 8, margin = { 1 } },
          'text3',
          'text4',
        },
        { 'div', style = { margin = 6 }, 'text2' },
      })

      local result = layout.execute(input)

      assert.same(result.y + 5, result.children[1].y)
      assert.same(result.children[1].y + 1 + 5, result.children[2].y)
      assert.same(result.children[2].y + 1 + 2, result.children[3].y)
      assert.same(result.children[3].y + 2 + 6, result.children[4].y)
    end)
  end)

  describe('flexbox', function()
    describe('row', function()
      it('Should lay out its children in columns by default', function()
        local input = parser.execute({
          style = { display = 'flex' },
          { 'div', 'text1' },
          { 'div', 'text2' },
        })

        local result = layout.execute(input)

        assert.same(0, result.children[1].x)
        assert.same(#'text2', result.children[2].x)
      end)

      it('Should strech its children to fill parent height', function()
        local input = parser.execute({
          style = { display = 'flex', height = 30 },
          { 'div', 'text1' },
          { 'div', 'text2' },
        })

        local result = layout.execute(input)

        assert.same(30, result.children[1].height)
        assert.same(30, result.children[2].height)
      end)
    end)

    describe('flex items', function()
      describe('flex property', function()
        it('Should divide it\'s width equally among its children', function()
          local input = parser.execute({
            style = { display = 'flex' },
            { 'div', style = { flex = { 1 } }, 'text1' },
            { 'div', style = { flex = { 1 } }, 'text2' },
          })

          local result = layout.execute(input)

          assert.same(result.width / 2, result.children[1].width)
          assert.same(result.width / 2, result.children[2].width)
        end)

        it(
          'Should divide it\'s width proportially to `flex` among its children',
          function()
            local input = parser.execute({
              style = { display = 'flex' },
              { 'div', style = { flex = { 1 } }, 'text1' },
              { 'div', style = { flex = { 2 } }, 'text2' },
            })

            local result = layout.execute(input)

            assert.same(result.width * 1 / 3, result.children[1].width)
            assert.same(result.width * 2 / 3, result.children[2].width)
          end
        )
      end)
    end)

    describe('alignment', function()
      describe('justify content', function()
        it(
          'Should align the components with the edges of the parent',
          function()
            local input = parser.execute({
              style = { display = 'flex', justifycontent = 'space-between' },
              { '', 'text1' },
              { '', 'text2' },
            })

            local result = layout.execute(input)

            assert.same(0, result.children[1].x)
            local child2End = result.children[2].x + result.children[2].width
            assert.same(result.width, child2End)
          end
        )
      end)
    end)

    describe('gap', function()
      local gap = 7
      it('Should have a gap between children', function()
        local input = parser.execute({
          style = { display = 'flex', gap = gap },
          { '', 'text1' },
          { '', 'text2' },
        })

        local result = layout.execute(input)

        local child1End = result.children[1].x + result.children[1].width
        assert.same(gap, result.children[2].x - child1End)
      end)
    end)
  end)

  describe('text', function()
    local fakeText = parser.execute({
      'Fake text',
    })

    ---@type LayoutObject
    local fakeTextLayout = {
      backgroundcolor = colors.background,
      border = default.block.style.border,
      children = {},
      color = colors.default,
      height = 1,
      margin = default.block.style.margin,
      padding = default.block.style.padding,
      text = 'Fake text',
      width = #'Fake text',
      x = 0,
      y = 0,
    }

    it('should layout a text node', function()
      local result = layout.execute(fakeText)

      assert.same(fakeTextLayout, result)
    end)

    it('should have default color and backgroundcolor', function()
      local input = parser.execute({ 'text' })

      local result = layout.execute(input)

      assert.same(default.text.style.color, result.color)
      assert.same(
        default.text.style.backgroundcolor,
        result.backgroundcolor
      )
    end)
  end)

  describe('children', function()
    it('should display children on different lines', function()
      local input = parser.execute({
        type = 'div',
        'child 1',
        'child 2',
        'child 3',
      })

      local result = layout.execute(input)

      for index = 1, 3 do
        assert.same(index - 1, result.children[index].y)
      end
    end)
  end)

  describe('block', function()
    local defaultBlockColor = default.block.style.color
    local defaultBlockBackgroundColor = default.block.style.backgroundcolor

    ---@type Component
    local fakeComponent = {
      { 'Fake text', style = { color = colors.primary } },
    }

    local fakeElement = parser.execute(fakeComponent)

    ---@type LayoutObject
    local fakeBlockLayout = {
      backgroundcolor = colors.background,
      border = default.block.style.border,
      children = {},
      color = colors.default,
      height = 1,
      margin = default.block.style.margin,
      padding = default.block.style.padding,
      width = 160,
      x = 0,
      y = 0,
    }

    it('should list children', function()
      ---@type Component
      local testComponent = {
        { 'child 1' },
        { 'child 2' },
        { 'child 3' },
      }

      local element = parser.execute(testComponent)
      local layoutObject = layout.execute(element)

      for index, child in ipairs(layoutObject.children) do
        assert.same(index - 1, child.y)
      end
    end)

    it('should apply padding if defined', function()
      local padding = 20

      ---@type Component
      local testComponent = {
        style = {
          padding = { padding },
          width = screenSize.tier3.width,
        },
        { 'child within padding' }
      }

      local element = parser.execute(testComponent)
      local layoutObject = layout.execute(element)

      assert.same(padding, layoutObject.children[1].x)
      assert.same(padding, layoutObject.children[1].y)
    end)

    it('should apply margin if defined', function()
      local margin = 20

      ---@type Component
      local testComponent = {
        {
          'text with margin',
          style = {
            margin = { margin },
            width = screenSize.tier3.width,
          },
        }
      }

      local element = parser.execute(testComponent)
      local layoutObject = layout.execute(element)

      assert.same(margin, layoutObject.children[1].x)
      assert.same(margin, layoutObject.children[1].y)
    end)

    it('should have default color and backgroundcolor', function()
      local input = parser.execute({ type = 'div' })

      local result = layout.execute(input)

      assert.same(default.block.style.color, result.color)
      assert.same(
        default.block.style.backgroundcolor,
        result.backgroundcolor
      )
    end)

    it('should layout a node with a text node child', function()
      local result = layout.execute(fakeElement)

      assert.same(
        merge(
          fakeBlockLayout,
          {
            backgroundcolor = defaultBlockBackgroundColor,
            children = result.children,
            color = defaultBlockColor,
          }
        ),
        result
      )
    end)
  end)

  describe('padding', function()
    local padding = 2

    it('Should not dislocate itself', function()
      local input = parser.execute({
        style = { padding = { padding } },
        { 'child 1' },
        { 'child 2' },
      })

      local result = layout.execute(input)

      assert.same(0, result.x)
      assert.same(0, result.y)
    end)

    it('Should move its children opposite to the padding direction', function()
      local input = parser.execute({
        style = { padding = { padding } },
        { 'child 1' },
        { 'child 2' },
      })

      local result = layout.execute(input)

      local childList = traverseBreadthFirst(result.children)

      assert.same(padding, childList[1].y)
      for _, child in ipairs(childList) do
        assert.same(padding, child.x)
      end
    end)

    it('should not inherit padding', function()
      local input = parser.execute({
        style = { padding = { padding } },
        { 'child 1' },
        { 'child 2' },
        { 'child 3' },
        { { 'nested child' }, { { 'deeply nested' } } }
      })

      local result = layout.execute(input)
      assert.same(0, result.x)

      local childList = traverseBreadthFirst(result.children)
      for _, child in ipairs(childList) do
        assert.same(padding, child.x)
      end
    end)
  end)

  describe('margin', function()
    local margin = 4

    it('Should dislocate itself opposite to the margin direction', function()
      local input = parser.execute({
        style = { margin = { margin } },
        { 'child 1' },
        { 'child 2' },
      })

      local result = layout.execute(input)

      assert.same(margin, result.x)
      assert.same(margin, result.y)
    end)

    it(
      'Should dislocate its children opposite to the margin direction',
      function()
        local input = parser.execute({
          style = { margin = { margin } },
          { 'child 1' },
          { 'child 2' },
        })

        local result = layout.execute(input)

        local childList = traverseBreadthFirst(result.children)

        assert.same(margin, childList[1].y)
        for _, child in ipairs(childList) do
          assert(margin, child.x)
        end
      end
    )

    it('should not inherit margin', function()
      local input = parser.execute({
        style = { margin = { margin } },
        { 'child 1' },
        { 'child 2' },
        { 'child 3' },
        { { 'nested child' }, { { 'deeply nested' } } }
      })

      local result = layout.execute(input)

      assert.same(margin, result.x)
      assert.same(margin, result.y)

      local childList = traverseBreadthFirst(result.children)

      assert.same(margin, childList[1].y)
      for _, child in ipairs(childList) do
        assert(margin, child.x)
      end
    end)

    it('should not interfere with sibling\'s margin', function()
      local input = parser.execute({
        { 'child 1',          style = { margin = { left = margin } } },
        { 'child 2' },
        { 'child 3' },
        { { 'nested child' }, { { 'deeply nested' } } }
      })

      local result = layout.execute(input)

      local childList = traverseBreadthFirst(result.children)

      assert.same(margin, childList[1].x)
      for i = 2, #childList do
        assert(0, childList[i].x)
      end
    end)
  end)

  describe('border', function()
    it('Should occupy space between margin and padding', function()
      local input = parser.execute({
        style = { padding = { 1, 3 }, border = { 1 } },
        { 'hello' }
      })

      local result = layout.execute(input)

      assert.same(4, result.children[1].x)
      assert.same(2, result.children[1].y)
    end)

    it('Should add to element height', function()
      local input = parser.execute({
        style = { padding = { 1 }, border = { 1 } },
        { 'hello' },
      })

      local result = layout.execute(input)

      assert.same(5, result.height)
    end)
  end)
end)
