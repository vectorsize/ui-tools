var handle = require('ui-lib/handle');
var d3    = require('d3');
// let UILoop = require('utils').UILoop;
// let loop = new UILoop(10);

var handleSVG = Object.assign(handle, {

  load() {
    // loop.start();
    this._xScale = d3.scale.linear().clamp(true);
    this._yScale = d3.scale.linear().clamp(true);

    let w = this.width() * 0.5;
    let h = this.height() * 0.5;

    let margin = {top:h, right:w, bottom:h, left:w};
    let offsetX = this._offsetX = margin.left + margin.right;// + this._surface.leftStyleOffset;
    let offsetY = this._offsetY = margin.top + margin.bottom;// + this._surface.topStyleOffset;

    let width = this._areaWidth - offsetX,
        height = this._areaHeight - offsetY;

    let $canvas = this._$canvas = d3.select(this._el);
    let $svg = ($canvas.select('svg')[0][0] && $canvas.select('svg') || $canvas.append('svg'))
      .attr("width", width + offsetX)
      .attr("height", height + offsetY);

    let $g = this._$g = (this.select() && $svg.select(this.select()) || $svg.append("g").attr('id', this.id()));

    this._$target = this.appendTarget($g);
    
    this._target = this._$target[0][0];
    this._g = this._$g[0][0];

    this._fixScales();

    // apply visual offsets
    if(!!~this._modes.indexOf('x')) margin.top += this.top();
    if(!!~this._modes.indexOf('y')) margin.left += this.left();

    this._$g.attr("transform", `translate(${margin.left}, ${margin.top})`);

    this.draw();

  },

  _removeMode(name) {
    let idx = this._modes.indexOf(name);
    this._modes.splice(idx, 1);
  },

  _fixScales() {
    
    let xRange = [0, this._areaWidth - this._offsetX];
    let yRange = [this._areaHeight - this._offsetY, 0];
    let empty = [0, 0];

    this._xScale.domain(xRange).range(xRange); // 1/1
    this._yScale.domain(yRange).range(yRange); // 1/1

    if(!!this.xDomain()){
      this._xScale.domain(this.xDomain());
    } else if(!!this.domain()) {
      this._xScale.domain(this.domain());
    } else {
      this._removeMode('x');
      this._xScale.range(empty);
    }

    if(!!this.yDomain()){
      this._yScale.domain(this.yDomain());
    } else if(!!this.domain()) {
      this._yScale.domain(this.domain());
    } else {
      this._removeMode('y');
      this._yScale.range(empty);
    }

  },

  // to be overriten
  appendTarget($g) { return $g; },

  update(e, callee) {
    if(!e) return;
    let active = this.targetMode() ? this._hit : this._hitTest(e);
    if(active){
      // let data = this.data();
      let {x, y} = e;
      let h = this.height();
      let w = this.width();
      
      // centers mouse interaction
      x -= w;
      y -= h;

      // to data
      let sx = this._xScale.invert(x),
          sy = this._yScale.invert(y);

      // do outside update
      let [xMin, xMax] = this.xClamp() || this.clamp() || this._xScale.domain(),
          [yMin, yMax] = this.yClamp() || this.clamp() || this._yScale.domain();

      // clamping x
      if(sx >= xMax) sx = xMax;
      if(sx <= xMin) sx = xMin;

      // clamping y
      if(sy >= yMax) sy = yMax;
      if(sy <= yMin) sy = yMin;

      // make it a full bar if fillmode
      if(this.fill()) this._$handle.attr('height', () => this._surface.height() - this._yScale(sy));


      this.x(sx);
      this.y(sy);

      this.emit('change', `value-${this.id()}`, {x:sx, y:sy});
      // loop.push(() => this.draw());
      // this._surface.loop.push(() => this.draw());
      this.draw();
    } 
  },

  draw(changes) {

    let dx = this.x() || 0,
        dy = this.y() || 0;

    // topixel
    let tx = this._xScale(dx),
        ty = this._yScale(dy);

    // fixes drawing offset
    tx -= this.width( ) * 0.5;
    ty -= this.height() * 0.5;

    this._$handleView.attr('transform', `translate(${tx}, ${ty})`);
  }

});

module.exports = handleSVG;