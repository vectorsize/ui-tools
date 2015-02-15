# TODO:
# 
# make a margin module that manipulates scales and sizes?
# handle all maring in a margin group
# append the shape inside a transport group that is the one that moves


Handle = require('ui-lib/handle')
plane  = require('ui-lib/svg/plane')
d3     = require('d3')
# UILoop = require('utils').UILoop
# loop = new UILoop(10)


class HandleSVG extends Handle

  constructor: ->
    return new HandleSVG unless @ instanceof HandleSVG
    super()

  # returns wether the click comes from our element
  isClicked: (e) ->
    if(!e) then return false
    node = if(!!e.target) then e.target else e
    if(node == @shapeEl) then return true
    @isClicked(node.parentNode)

  draw: (shape) ->
    @shape = shape
    
    @canvas = d3.select(@el)
      .append('svg')

    # define svg as a G element that translates the origin to the top-left corner of the chart area.
    @canvas
      .attr("width",  @width()  + @offsetx)
      .attr("height", @height() + @offsety)

    # factoring out the margin funk

    context = plane()
      .id(@id)
      .top(@top())
      .left(@left())
      .right(@right())
      .bottom(@bottom())
    
    @xscale = context.xscale()
    @yscale = context.yscale()

    # now draw some action

    @context = context.mount(@canvas)
    @el = @shape.draw(@)


  update: (e) ->

    # console.log @x(), @xToData(e.x)
    # if @targetMode && !@clicked then return
    # center interaction based on the center of the handle
    
    # delegates position to shape
    @shape
      .x(@x())
      # .y(@yToData(@y()))
      .update()
    # @el.attr("transform", "translate(#{@xToData(@x())}, #{@yToData(@y())})")
    
    # console.log @xscale(@x())

module.exports = HandleSVG
