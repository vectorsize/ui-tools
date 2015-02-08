
handleSVG = require 'ui-lib/svg/handle'

rect = Object.assign( handleSVG, {
    
  appendTarget: ($g) ->

    @_$handleView = $g
      .append("g")
        .attr("class", 'handle-view')
        .attr('stroke-width', 0)
    
    @_$handle = @_$handleView.append("rect")
        .attr("class", "thumb thumb-#{@id()}")
        .attr("width", @width())
        .attr("height", @height())
        .style('fill', @color())
        .style('shape-rendering', 'crispEdges')

    @_$handle

})

module.exports = rect