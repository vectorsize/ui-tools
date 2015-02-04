
let obj = require('tools/object'),
    {bind, chain, accessors, emmiter} = obj;

var handle = {
  
  _$g: null,
  _target: null,
  _xScale: [],
  _yScale: [],
  _$handle: null,
  _$canvas: null,
  _areaWidth: 0,
  _areaHeight: 0,
  _offsetX: 0,
  _offsetY: 0,
  _hit: false,

  create: function() {

    let accessorList = [
      'id', 'data', 'bind',
      'domain', 'xDomain', 'yDomain',
      'clamp', 'xClamp', 'yClamp',
      'x', 'y', 'width', 'height',
      'top', 'left',
      'targetMode',
      'modes',
      'select',
      'color',
      'pad',
      'fill',
      'step'
    ];

    let instance = chain(Object.create(this))
      // middleware
      .use(emmiter)
      .use(accessors, accessorList)
      .and(bind, ['_mouseDown', '_mouseUp', 'update'])
      // initialize
      .targetMode(true)
      .left(0)
      .top(0)
      .color("steelblue");

    instance._modes = ['x','y'];

    return instance;
  },

  _load: function(surface) {

    this._surface = surface;
    this._el = surface._el;
    this._areaWidth = surface.width();
    this._areaHeight = surface.height();

    this._surface.on('mousedown', this._mouseDown);
    this._surface.on('mouseup', this._mouseUp);
    this._surface.on('mousemove', this.update);

    this.load();
  },

  _mouseDown(e) {
    this._hit = this._hitTest(e);
  },

  _mouseUp(e) { 
    this._hit = false;
  },


  _isClicked(e) {
    if(!e) return false;
    let node = e.target || e;
    if(node === this._g || node === this._target) return true;
    return this._isClicked(node.parentNode);
  },

  _hitTest(e) {
    let hit = false;
    if(!e) return hit;

    if(this.targetMode()) {
      hit = this._isClicked(e);
    } else {
        let srf = this._surface;
      if(!!~this._modes.indexOf('y')) {
        let left = this.left() - this.pad();
        let right = this.left() + this.width() + this.pad();
        hit = srf.x >= left && srf.x <= right && srf.which === 1;
      } else {
        let top = this.top() - this.pad();
        let bottom = this.top() + this.height() + this.pad();
        hit = srf.y >= top && srf.y <= bottom && srf.which === 1;
      }

    }

    this._hit = hit;
    return hit;
  },

  //  to be overriden
  update(){},
  load(){},

};

module.exports = handle;