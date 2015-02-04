var HandleSVG = require('../handle');

class RoundSVG extends HandleSVG {

  constructor() { if (!(this instanceof RoundSVG)) return new RoundSVG();
    super();
  }

  init(){
    this.size(this.size()*0.5);
    super.init();
  }

  _fixMargin(){
    let r = this.size();
    let margin = this.margin();
    // let sum = (prop) => margin[prop] + o[prop];
    let sum = (prop) => margin[prop] + (r);
    return {top:sum('top'), right:sum('right'), bottom:sum('bottom'), left:sum('left')};
  }

  _fixEvents(e) {
    let d = this.size()*0.75; // mouse shape quirks

    // fix diametre 'padding'
    e.x -= d;
    e.y -= d;

    return e;
  }
  _appendTarget($g) {
    let r = this.size();
    let d = r*2;

    this._$handle = $g
      .append("circle")
        // .style("cursor", "default")
        .attr("class", `thumb thumb-${this.id()}`)
        .attr("r", r)
        .style('fill', this.color());
    
    return this._$handle[0][0];
  }

}

module.exports = RoundSVG;