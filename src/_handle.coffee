
{bind, chain, accessors, emmiter} = require('tools/object')

handle =
  
  _$g: null
  _target: null
  _xScale: []
  _yScale: []
  _$handle: null
  _$canvas: null
  _areaWidth: 0
  _areaHeight: 0
  _offsetX: 0
  _offsetY: 0
  _hit: false

  create: () ->

    accessorList = [
      'id', 'data', 'bind',
      'domain', 'xDomain', 'yDomain',
      'clamp', 'xClamp', 'yClamp',
      'x', 'y', 'width', 'height',
      'top', 'left',
      'targetMode',
      'modes',
      'select',
      'color',
      'pad',
      'fill',
      'step'
    ]

    instance = chain(Object.create(@))
      # middleware
      .use(emmiter)
      .use(accessors, accessorList)
      .and(bind, ['_mouseDown', '_mouseUp', 'update'])
      # initialize
      .targetMode(true)
      .left(0)
      .top(0)
      .color("steelblue")

    instance._modes = ['x','y']

    instance


  _load: (surface) ->

    @._surface = surface
    @._el = surface._el
    @._areaWidth = surface.width()
    @._areaHeight = surface.height()

    @._surface.on('mousedown', @._mouseDown)
    @._surface.on('mouseup', @._mouseUp)
    @._surface.on('mousemove', @.update)

    @.load()


  _mouseDown: (e) ->
    @._hit = @._hitTest(e)
    @.update(e)


  _mouseUp: (e) ->
    @._hit = false


  _isClicked: (e) ->
    return false if(!e)
    node = e.target || e
    return true if(node == @._g || node == @._target)
    return @._isClicked(node.parentNode)


  _hitTest: (e) ->
    hit = false
    srf = @._surface
    
    return hit if(!e)

    if @.targetMode()
      hit = @._isClicked(e)
    else

      if !!~@._modes.indexOf('y')
        left  = @.left() - @.pad()
        right = @.left() + @.width() + @.pad()
        
        hit = srf.x >= left && srf.x <= right && srf.which == 1
      else
        top    = @.top() - @.pad()
        bottom = @.top() + @.height() + @.pad()
        
        hit = srf.y >= top && srf.y <= bottom && srf.which == 1


    @._hit = hit


  #  to be overriden
  update: () -> {}
  load: () -> {}

module.exports = handle