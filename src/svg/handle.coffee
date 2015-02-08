Handle = require('ui-lib/handle')
d3     = require('d3')
# UILoop = require('utils').UILoop
# loop = new UILoop(10)


class HandleSVG extends Handle


  constructor: () ->
    return new HandleSVG unless @ instanceof HandleSVG
    super()


  # centers given x and y based on a given size rectangle
  center: (x, y, rect) -> 
    x: x - rect.width   * 0.5 - @offsetx
    y: y - rect.height  * 0.5 - @offsety


  toDom: ($el) -> $el[0][0]


  domSize: ($el) ->
    @toDom($el).getBoundingClientRect()


  append: ($head) ->
    super($head)

    @canvas  = d3.select(@el)
      .append('svg')
    @context = @canvas.append('g')
      .attr("class", "context #{@id}")
  
    @handle = $head(@context) # ioc
    
    # once we have the handle we fix so that
    # he later offset keeps the data consistent
    @area = @domSize(@handle)
    w = @area.width  * 0.5
    h = @area.height * 0.5
    @_xdomain[0] += w
    @_ydomain[0] += h
    @_xdomain[1] += w    

    @updateScales()

    @canvas
      .attr("width",  @width  + @offsetx)
      .attr("height", @height + @offsety)

    @context
      .attr("transform", "translate(#{@left()}, #{@top()})")


  update: () ->
    # center interaction based on the center of the handle
    {x, y} = @center @x(), @y(), @area
    @handle.attr("transform", "translate(#{x}, #{y})")
    console.log @xToData(@x()), @yToData(@y())


module.exports = HandleSVG