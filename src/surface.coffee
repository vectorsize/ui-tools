
# _ = require('lodash')
{bind, chain, accessors, emmiter} = require('tools/object')
{uniqueId:uid, UILoop} = require('utils')

int = (string) -> parseInt(string, 10) || 0
# loop = new UILoop(40)

surface =

  _el: null
  _target: null
  _clicked: false
  _offsetX: 0
  _offsetY: 0
  _elements: []

  create: () ->
    instance = chain(Object.create(@))
      .use(emmiter)
      .use(accessors, ['width', 'height'], true)
      .and(bind, ['_mouseDown', '_mouseUp', '_mouseMove'])

    instance._clicked = false
    instance._elements = []
    instance.scrollLeft = 0
    instance.scrollTop = 0
    # loop.start()
    instance
  
   # returns wether the click comes from our element
  _isClicked: (e) ->
    if(!e) then return false
    node = e.target || e
    if(node == @._el) then return true
    @._isClicked(node.parentNode)

  _listeners:(target, action = 'add') ->
    target["#{action}EventListener"]('mouseleave', @._mouseUp)
    target["#{action}EventListener"]('mouseup', @._mouseUp)
    target["#{action}EventListener"]('mousemove', @._mouseMove)

  _updateOffsets:() ->
    @.scrollTop = window.pageYOffset - document.documentElement.clientTop
    @.scrollLeft = window.pageXOffset - document.documentElement.clientLeft

  _mouseDown:(e) ->
    @._listeners(document.body, 'add')
    clicked = @._clicked = @._isClicked(e)
    
    if(clicked)
      @._updateOffsets()
      @.emit('mousedown', @._formatEvent(e))
      # loop.push(() -> @.emit('mousedown', e))

  _formatEvent:(e) ->
    x = @.x = (e.x - @._offsetX) + @.scrollLeft
    y = @.y = (e.y - @._offsetY) + @.scrollTop
    target = @.target = e.target
    @.which = e.which
    
    {x ,y, target, originalEvent:e}

  _mouseMove:(e) ->
    if(@._clicked)
      @.emit('mousemove', @._formatEvent(e))
      # loop.push(() -> @.emit('mousemove', {x ,y, target: e.target, originalEvent:e}))

  _mouseUp:(e) ->
    @._clicked = false
    @.emit('mouseup', e)
    # loop.push(() -> @.emit('mouseup', e))
    @._listeners(document.body, 'remove')

  _offsets:(styles, which) ->
    m = int(styles["margin-#{which}"])
    p = int(styles["padding-#{which}"])
    b = int(styles["border-#{which}-width"])
    
    {m, b, p}

  select:(selector=null) ->
    if(!selector) then return new Error('An element querySelector must be specified.')
    el = document.querySelector(selector)
    el.innerHTML = ''
    el.addEventListener('mousedown', @._mouseDown)

    styles = window.getComputedStyle(el)
    clientRect = el.getBoundingClientRect()
    
    # extract margin, border and padding
    {m:mt, b:bt, p:pt} = @._offsets(styles, 'top')
    {m:mr, b:br, p:pr} = @._offsets(styles, 'right')
    {m:mb, b:bb, p:pb} = @._offsets(styles, 'bottom')
    {m:ml, b:bl, p:pl} = @._offsets(styles, 'left')

    @._offsetX = clientRect.left + (ml + bl + pl)
    @._offsetY = clientRect.top  + (mt + bt + pt)

    @.width( clientRect.width  - ( (bl + pl) + (br + pr) ))
    @.height(clientRect.height - ( (bt + pt) + (bb + pb) ))

    @._el = el
    @._target = el

    @

  draw:(el) ->
    el.id(el.id() || uid()+1)
    el._load(@)
    @._elements.push(el)
    @

  update:(changes) ->
    @._elements.forEach((e) -> e.draw(changes, true))
    return

  delete:(el) ->
    els = @._elements
    idx = @._elements.indexOf(el)
    if(!!~idx)
      el._listeners(@, 'remove')
      g = el._$g[0][0]
      g.parentNode.removeChild(g)
      els.splice(idx, 1)


module.exports = surface
