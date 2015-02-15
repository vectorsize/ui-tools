
#  = require('lodash')
{bind, chain, accessors, emmiter} = require('tools/object')
{uniqueId:uid, UILoop} = require('utils')

int = (string) -> parseInt(string, 10) || 0
# loop = new UILoop(40)

# only talks pixels
class Surface

  el: null
  target: null
  clicked: false
  offsetX: 0
  offsetY: 0
  elements: []
  anchor:
    x: 0
    y: 0

  constructor: ->
    return new Surface() unless @ instanceof Surface

    chain(@)
      .use(emmiter)
      .use(accessors, ['width', 'height'], true)
      .and(bind, ['mouseDown', 'mouseUp', 'mouseMove'])

    @clicked    = false
    @elements   = []
    @scrollLeft = 0
    @scrollTop  = 0

    # loop.start()
  
  # returns wether the click comes from our element
  isClicked: (e) ->
    if(!e) then return false
    node = e.target || e
    if(node == @el) then return true
    @isClicked(node.parentNode)

  listeners: (target, action = 'add') ->
    target["#{action}EventListener"]('mouseleave', @mouseUp)
    target["#{action}EventListener"]('mouseup', @mouseUp)
    target["#{action}EventListener"]('mousemove', @mouseMove)

  updateOffsets: ->
    @scrollTop = window.pageYOffset - document.documentElement.clientTop
    @scrollLeft = window.pageXOffset - document.documentElement.clientLeft

  mouseDown: (e) ->
    @listeners(document.body, 'add')
    clicked = @clicked = @isClicked(e)

    if(clicked)
      @updateOffsets()
      @anchor = 
        x: e.x
        y: e.y

      @emit('mousedown', @formatEvent(e))
      # loop.push(() -> @emit('mousedown', e))

  computePositions: (e) ->
    x: (e.x - @offsetX) + @scrollLeft
    y: (e.y - @offsetY) + @scrollTop

  formatEvent: (e) ->
    target  = e.target || e.relatedTarget || e.fromElement || e.toElement
    @target = target
    delta   = e.delta
    {x, y}  = @computePositions(e)
    {x ,y, target, delta, originalEvent:e}

  mouseMove: (e) ->
    e.delta = 
      x: e.x - @anchor.x
      y: e.y - @anchor.y

    @emit('mousedrag', @formatEvent(e))
    # loop.push(() -> @emit('mousemove', {x ,y, target: e.target, originalEvent:e}))

  mouseUp: (e) ->
    @clicked = false
    @anchor  = {x: 0, y: 0}

    @emit('mouseup', e)
    # loop.push(() -> @emit('mouseup', e))
    @listeners(document.body, 'remove')

  offsets: (styles, which) ->
    m = int(styles["margin-#{which}"])
    p = int(styles["padding-#{which}"])
    b = int(styles["border-#{which}-width"])
    
    {m, b, p}

  select: (selector=null) ->
    if(!selector) then return new Error('An element querySelector must be specified.')
    el = document.querySelector(selector)
    el.innerHTML = ''
    el.addEventListener('mousedown', @mouseDown)

    styles = window.getComputedStyle(el)
    clientRect = el.getBoundingClientRect()
    
    # extract margin, border and padding
    {m:mt, b:bt, p:pt} = @offsets(styles, 'top')
    {m:mr, b:br, p:pr} = @offsets(styles, 'right')
    {m:mb, b:bb, p:pb} = @offsets(styles, 'bottom')
    {m:ml, b:bl, p:pl} = @offsets(styles, 'left')

    @offsetX = clientRect.left + (ml + bl + pl)
    @offsetY = clientRect.top  + (mt + bt + pt)

    @width( clientRect.width  - ( (bl + pl) + (br + pr) ))
    @height(clientRect.height - ( (bt + pt) + (bb + pb) ))

    @el = el
    @target = el

    @

module.exports = Surface
