
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
  
  constructor: () ->
    return new Handle unless @ instanceof Handle

    accessorList = ['xdomain', 'ydomain', 'xrange', 'yrange', 'top', 'right', 'bottom', 'left', 'clamps']

    chain(@)
      # middleware
      .use(emmiter)
      .use(accessors, accessorList)
      # .and(bind, ['_mouseDown', '_mouseUp', 'update'])
      # .targetMode(true)
    
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


  updateScales: () ->
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


  clamp: (value, extent) ->
    min = extent[0]
    max = extent[1]
    if(value <= min or value >= max)
      return Math.min(Math.max(value, Math.min(min, max)), Math.max(min, max))
    value


  # sets value to transform translate x in data
  x: (v=null) ->
    if v == null then return @_x
    # x = @xscale v
    @_x = if @clamps() then @clamp(v, @xdomain()) else v
    @


  # sets value to transform translate y in data
  y: (v=null) ->
    if v == null then return @_y
    # y = @yscale v
    @_y = if @clamps() then @clamp(v, @ydomain()) else v
    @


  # selector for the container
  select: (sel) ->
    @$el = $(sel)
    @el  = @$el[0]
    @id  = slugify sel
    @


  # receives an element to be drawn
  append: () ->
    @margin  = {top:@top(), right:@right(), bottom:@bottom(), left:@left()}
    @offsetx = @margin.left + @margin.right
    @offsety = @margin.top  + @margin.bottom
    # canvas  should have offsets added
    # context should be offseted by left + top
    # reference size gets updated based on the margins
    @width   = @_xdomain[1] - @offsetx
    @height  = @_ydomain[1] - @offsety
    # scales are set accordingly
    @_xdomain[0] = @margin.left
    @_ydomain[0] = @margin.top
    @_xdomain[1] = @width 
    @_ydomain[1] = @height
    @updateScales()


  # scales binding
  xToData:  (v) -> @xscale v
  xToPixel: (v) -> @xscale.invert v
  
  yToData:  (v) -> @yscale v
  yToPixel: (v) -> @yscale.invert v

  # shortcut to transforms
  # transform: () ->

  # sets rotation to transform rotate
  rotate: () ->

  # method to apply the state
  # basically tranform translate x y etc
  update: () ->

module.exports = Handle