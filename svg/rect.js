var handleSVG = require('ui-lib/svg/handle');

let rect = Object.assign(handleSVG, {
    
  appendTarget($g) {

    this._$handleView = $g
      .append("g")
        .attr("class", 'handle-view')
        .attr('stroke-width', 0);
    
    this._$handle = this._$handleView.append("rect")
        .attr("class", `thumb thumb-${this.id()}`)
        .attr("width", this.width())
        .attr("height", this.height())
        .style('fill', this.color())
        .style('shape-rendering', 'crispEdges');

    return this._$handle;
  }

});

module.exports = rect;