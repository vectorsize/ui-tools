// Generated by CoffeeScript 1.9.0
var handleSVG, rect;

handleSVG = require('ui-lib/svg/handle');

rect = Object.assign(handleSVG, {
  appendTarget: function($g) {
    this._$handleView = $g.append("g").attr("class", 'handle-view').attr('stroke-width', 0);
    this._$handle = this._$handleView.append("rect").attr("class", "thumb thumb-" + (this.id())).attr("width", this.width()).attr("height", this.height()).style('fill', this.color()).style('shape-rendering', 'crispEdges');
    return this._$handle;
  }
});

module.exports = rect;

//# sourceMappingURL=rect.js.map
