
{bind, chain, accessors, emmiter} = require('tools/object')
{scale} = require('tools/d3-scales')
d3      = require('d3')

class Plane

# plane()
#  .top(10)
#  .left(10)
#  .right(10)
#  .bottom(10)
#  .domain([0, 1])
#  .range([0, 100])
#  .xscale()
#  .yscale()

  constructor: ->
    return new Plane unless @ instanceof Plane

    accessorList = [
      'id'
      'width', 'height'
      'xscale', 'yscale'
      'top', 'right', 'bottom', 'left'
      'clamps'
    ]

    # middleware
    chain(@)
      .use(accessors, accessorList)

    # initialise scales
    @xscale = scale.linear()
    @yscale = scale.linear()

    # margins
    @top    0
    @right  0
    @bottom 0
    @left   0

    @width  0
    @height 0

  clamp: (value, extent) ->
    min = extent[0]
    max = extent[1]
    if(value <= min or value >= max)
      return Math.min(Math.max(value, Math.min(min, max)), Math.max(min, max))
    value


  mount: (context) ->

    @offsetx = @left + @right
    @offsety = @top  + @bottom
    @width   @width()  - @offsetx
    @height  @height() - @offsety

    @xscale.domain [@left(), @width() + @left()]
    @yscale.domain [@top(), @height() + @top()]

    @g = context.append('g')
      .attr("class", "margin-#{@id} margin")
      .attr("transform", "translate(#{@left()}, #{@top()})")

    # visible area
    @area = context
      .append('rect')
      .attr("width", @width())
      .attr("height", @height())
      .attr("fill", "red")
      .style({"opacity": 0.25, "pointer-events":'none'})

    @


module.exports = Plane