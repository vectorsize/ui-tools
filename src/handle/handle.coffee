
$ = require('sizzle')
{bind, chain, accessors, emmiter} = require('tools/object')
{scale} = require('tools/d3-scales')
slugify = require('slugify')
# scale = require('tools/scales')

# only talks data except for the scales
# handles margins
class Handle

  _x:  0
  _y:  0
  id:  null
  $el: null
  el:  null
  context: null
  canvas:  null
  handle:  null # needed?
  xscale:  null
  yscale:  null
  width:   0
  height:  0
  clicked:  false
  targetMode: true
  
  constructor: ->
    return new Handle unless @ instanceof Handle

    accessorList = [
      'width'
      'height'
      'xdomain'
      'ydomain'
      'xrange'
      'yrange'
      'top'
      'right'
      'bottom'
      'left'
      'clamps'
    ]

    # middleware
    chain(@)
      .use(emmiter)
      .use(accessors, accessorList)
      .use(bind, ['mousedown', 'mouseup'])
    
    # margins
    @top    0
    @right  0
    @bottom 0
    @left   0
    @clamps true

    @offsetx = 0
    @offsety = 0

    # initialise scales
    @xscale = scale.linear()
    @yscale = scale.linear()

    # set default scales values
    defScales = [0, 1]
    @xdomain  defScales, defScales
    @xrange   defScales, defScales
    @ydomain  defScales, defScales
    @yrange   defScales, defScales
    @domain   defScales, defScales
    @range    defScales, defScales

    @updateScales()

  updateScales: ->
    @xscale.domain(@xdomain()).range(@xrange())
    @yscale.domain(@ydomain()).range(@yrange())
    return

  flip: (which) ->
    range = "#{which}range"
    @[range]([@[range]()[1], @[range]()[0]])
    console.log @[range]()

  # combined domain setter/getter
  domain: (xval = null, yval = null) ->
    if(xval == null) then return [@xdomain(), @ydomain()]
    @xdomain xval
    y = if(yval == null) then xval else yval
    @ydomain y
    @updateScales()
    @

  # combined range setter/getter
  range: (xval = null, yval = null) ->
    if(xval == null) then return [@xrange(), @yrange()]
    @xrange xval
    y = if(yval == null) then xval else yval
    @yrange y
    @updateScales()
    @

  mousedown: (e) -> @clicked = @isClicked(e)
  mouseup  : (e) -> @clicked = false

  # centers given x and y based on a given object
  center: (x, y, o) -> 
    x: x - o.width()  * 0.5 # - @offsetx
    y: y - o.height() * 0.5 # - @offsety

  clamp: (value, extent) ->
    min = extent[0]
    max = extent[1]
    if(value <= min or value >= max)
      return Math.min(Math.max(value, Math.min(min, max)), Math.max(min, max))
    value

  # sets value to transform translate x in data
  x: (v=null) ->
    if v == null then return @_x
    # clampVal = [@_xdomain[0] + @margins.left, @_xdomain[1] - @margins.right]
    # console.log v, clampVal
    # v -= @shape.halfWidth()
    @_x = if @clamps() then @clamp(v, @xdomain()) - @margins.left else v
    @

  # sets value to transform translate y in data
  y: (v=null) ->
    if v == null then return @_y
    clampVal = @ydomain()
    @_y = if @clamps() then @clamp(v, @ydomain()) - @margins.top else v
    @

  # selector for the container
  select: (sel) ->
    @$el = $(sel)
    @el  = @$el[0]
    @id  = slugify sel
    @

  # applies margin conventions as explained here http://bl.ocks.org/mbostock/3019563
  fixmargins: ->
    @margins = 
      top: @top()
      left: @left()
      right: @right()
      bottom: @bottom()

    @offsetx = @margins.left + @margins.right
    @offsety = @margins.top  + @margins.bottom

    # define width and height as the inner dimensions of the context area.
    # @width   = @_xdomain[1] - @offsetx
    # @height  = @_ydomain[1] - @offsety
    @width   @width()  - @offsetx # - @shape.halfWidth()
    @height  @height() - @offsety

    # define svg as a G element that translates 
    # the origin to the top-left corner of the chart area.
    # in the subclass

    # re-sset scales accordingly
    @xdomain [@left(), @width()+@left()]
    @ydomain [@top(), @height()+@top()]

    @updateScales()


  # scales binding
  xToData:  (v) -> @xscale v
  xToPixel: (v) -> @xscale.invert v
  
  yToData:  (v) -> @yscale v
  yToPixel: (v) -> @yscale.invert v

  mousedown: (e) ->
  mouseup  : (e) ->

  # sets rotation to transform rotate
  rotate: ->

  # method to apply the state
  # basically tranform translate x y etc
  # update: ->

module.exports = Handle
