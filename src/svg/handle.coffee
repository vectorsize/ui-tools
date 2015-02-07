handle = require('ui-lib/handle')
d3    = require('d3')
# UILoop = require('utils').UILoop
# loop = new UILoop(10)

handleSVG = Object.assign(handle, {

  load: () ->
    # loop.start()
    @._xScale = d3.scale.linear().clamp(true)
    @._yScale = d3.scale.linear().clamp(true)

    w = @.width() * 0.5
    h = @.height() * 0.5

    margin  = {top:h, right:w, bottom:h, left:w}
    offsetX = @._offsetX = margin.left + margin.right  # + @._surface.leftStyleOffset
    offsetY = @._offsetY = margin.top  + margin.bottom # + @._surface.topStyleOffset

    width  = @._areaWidth - offsetX
    height = @._areaHeight - offsetY

    $canvas = @._$canvas = d3.select(@._el)
    $svg = ($canvas.select('svg')[0][0] && $canvas.select('svg') || $canvas.append('svg'))
      .attr("width", width + offsetX)
      .attr("height", height + offsetY)

    $g = @._$g = (@.select() && $svg.select(@.select()) || $svg.append("g").attr('id', @.id()))

    @._$target = @.appendTarget($g)
    
    @._target = @._$target[0][0]
    @._g = @._$g[0][0]

    @._fixScales()

    # apply visual offsets
    margin.top += @.top() if !!~@._modes.indexOf('x')
    margin.left += @.left() if !!~@._modes.indexOf('y')

    @._$g.attr("transform", "translate(#{margin.left}, #{margin.top})")

    @.draw()


  _hasMode: (which) -> !!~@._modes.indexOf(which)

  _removeMode: (name) ->
    idx = @._modes.indexOf(name)
    @._modes.splice(idx, 1)


  _fixScales: () ->
    
    xRange = [0, @._areaWidth - @._offsetX]
    yRange = [@._areaHeight - @._offsetY, 0]
    empty = [0, 0]

    @._xScale.domain(xRange).range(xRange) # 1/1
    @._yScale.domain(yRange).range(yRange) # 1/1

    if (!!@.xDomain())
      @._xScale.domain(@.xDomain())
     else if(!!@.domain())
      @._xScale.domain(@.domain())
    else
      #@._removeMode('x')
      @._xScale.range(empty)


    if(!!@.yDomain())
      @._yScale.domain(@.yDomain())
    else if(!!@.domain())
      @._yScale.domain(@.domain())
    else
      #@._removeMode('y')
      @._yScale.range(empty)


  # to be overriten
  appendTarget:($g) -> $g

  update:(e, callee) ->
    if(!e) then return

    # let active = this.targetMode() ? this._hit : this._hitTest(e);
    # if(active) …

    # active = if @.targetMode() then @._hit else @._hitTest(e)
    if !(if @.targetMode() then @._hit else @._hitTest(e)) then return

    # if(!active) then return

    # data = @.data()
    {x, y} = e
    h = @.height() * 0.5
    w = @.width() * 0.5
    
    # centers mouse interaction
    x -= w
    y -= h

    # to data
    sx = @._xScale.invert(x)
    sy = @._yScale.invert(y)

    # do outside update
    [xMin, xMax] = @.xClamp() || @.clamp() || @._xScale.domain()
    [yMin, yMax] = @.yClamp() || @.clamp() || @._yScale.domain()

    # clamping x
    if(sx >= xMax) then sx = xMax
    if(sx <= xMin) then sx = xMin

    # clamping y
    if(sy >= yMax) then sy = yMax
    if(sy <= yMin) then sy = yMin


    if(@._hasMode('x')) then @.x(sx)
    if(@._hasMode('y')) then @.y(sy)

    @.emit('change', "value-#{@.id()}", {x:sx, y:sy})
    # loop.push(() => @.draw())
    # @._surface.loop.push(() => @.draw())
    @.draw()

  draw:(changes) ->

    # from domain
    dx = @.x() || 0
    dy = @.y() || 0

    # topixel
    tx = @._xScale(dx)
    ty = @._yScale(dy)

    # fixes drawing offset ?
    ty -= @.height() * 0.5
    tx -= @.width() * 0.5
    
    if(@.fill() && @._hasMode('y')) then @._$handle.attr('height', @._surface.height() - ty)

    # make it a full bar if fillmode
    if(@.fill() && @._hasMode('x'))
      @._$handle.attr('width', tx + @.width() * 2) # fill al the space
      tx -= (@._$handle.attr('width') - @.width()) # stick to the left

    @._$handleView.attr('transform', "translate(#{tx}, #{ty})")
  
})

module.exports = handleSVG