
{bind, chain, accessors, emmiter} = require('tools/object')
Shape = require('ui-lib/shape')
{scale} = require('tools/d3-scales')

class ShapeSVG extends Shape

  constructor: ->
    return new ShapeSVG unless @ instanceof ShapeSVG
    super()

    accessorList = ['width', 'height']

    # middleware
    chain(@)
      .use(accessors, accessorList)
      .use(bind, 'draw')

    @x 0
    @y 0
    @xscale = scale.linear()
    @yscale = scale.linear()

  # centered x
  x: (v=null) ->
    if v == null then return @_x
    @_x = v - @halfWidth()
    @

  # centered y
  y: (v=null) ->
    if v == null then return @_y
    @_y = v - @halfHeight()
    @

  halfWidth : -> @.width()  * 0.5
  halfHeight: -> @.height() * 0.5

  draw: (@handle) ->
    # @xscale
    #   .domain @handle.xdomain()
    #   .range [
    #     @handle.xrange()[0] - @halfWidth()
    #     @handle.xrange()[1] - @halfWidth()
    #   ]

    @context = @handle.context.append('g')
    
    @context.append("rect")
      .attr("width" , @width())
      .attr("height", @height())

  update: ->
    @context.attr("transform", "translate(#{@x()}, 0)")
    # console.log @xscale(@x())
    # @context.attr("transform", "translate(#{@x()-@halfWidth()}, #{@y()-@halfHeight()})")


module.exports = ShapeSVG
