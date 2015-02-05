
// let _ = require('lodash');
let obj = require('tools/object'),
    {bind, chain, accessors, emmiter} = obj;

let int = (string) => parseInt(string, 10) || 0;
let {uniqueId:uid, UILoop} = require('utils');
// let loop = new UILoop(40);

let surface = {

  _el: null,
  _target: null,
  _clicked: false,
  _offsetX: 0,
  _offsetY: 0,
  _elements: [],

  create() {
    let instance = chain(Object.create(this))
      .use(emmiter)
      .use(accessors, ['width', 'height'], true)
      .and(bind, ['_mouseDown', '_mouseUp', '_mouseMove']);

    instance._clicked = false;
    instance._elements = [];
    instance.scrollLeft = 0;
    instance.scrollTop = 0;
    // loop.start();
    return instance;
  },

   // returns wether the click comes from our element
  _isClicked(e) {
    if(!e) return false;
    let node = e.target || e;
    if(node === this._el) return true;
    return this._isClicked(node.parentNode);
  },

  _listeners(target, action = 'add') {
    target[`${action}EventListener`]('mouseleave', this._mouseUp);
    target[`${action}EventListener`]('mouseup', this._mouseUp);
    target[`${action}EventListener`]('mousemove', this._mouseMove);
  },

  _updateOffsets() {
    this.scrollTop = window.pageYOffset - document.documentElement.clientTop;
    this.scrollLeft = window.pageXOffset - document.documentElement.clientLeft;
  },

  _mouseDown(e) {
    this._listeners(document.body, 'add');
    let clicked = this._clicked = this._isClicked(e);
    if(clicked) {
      this._updateOffsets();
      this.emit('mousedown', this._formatEvent(e));
      // loop.push(() => this.emit('mousedown', e));
    }
  },

  _formatEvent(e) {
    let x = this.x = (e.x - this._offsetX) + this.scrollLeft;
    let y = this.y = (e.y - this._offsetY) + this.scrollTop;
    let target = this.target = e.target;
    this.which = e.which;
    return {x ,y, target, originalEvent:e};
  },

  _mouseMove(e) {
    if(this._clicked) {
      this.emit('mousemove', this._formatEvent(e));
      // loop.push(() => this.emit('mousemove', {x ,y, target: e.target, originalEvent:e}));
    }
  },

  _mouseUp(e) {
    this._clicked = false;
    this.emit('mouseup', e);
    // loop.push(() => this.emit('mouseup', e));
    this._listeners(document.body, 'remove');
  },

  _offsets(styles, which) {
    let m = int(styles[`margin-${which}`]);
    let p = int(styles[`padding-${which}`]);
    let b = int(styles[`border-${which}-width`]);
    return {m, b, p};
  },

  select(selector=null) {
    if(!selector) return new Error('An element querySelector must be specified.');
    let el = document.querySelector(selector);
    el.innerHTML = '';
    el.addEventListener('mousedown', this._mouseDown);

    let styles = window.getComputedStyle(el);
    let clientRect = el.getBoundingClientRect();
    
    // extract margin, border and padding
    let {m:mt, b:bt, p:pt} = this._offsets(styles, 'top');
    let {m:mr, b:br, p:pr} = this._offsets(styles, 'right');
    let {m:mb, b:bb, p:pb} = this._offsets(styles, 'bottom');
    let {m:ml, b:bl, p:pl} = this._offsets(styles, 'left');

    this._offsetX = clientRect.left + (ml + bl + pl);
    this._offsetY = clientRect.top  + (mt + bt + pt);

    this.width( clientRect.width  - ( (bl + pl) + (br + pr) ));
    this.height(clientRect.height - ( (bt + pt) + (bb + pb) ));

    this._el = el;
    this._target = el;

    return this;
  },

  draw(el){
    el.id(el.id() || uid()+1);
    el._load(this);
    this._elements.push(el);
    return this;
  },

  update(changes) {
    this._elements.forEach((e) => e.draw(changes, true));
  },

  delete(el){
    let els = this._elements;
    let idx = this._elements.indexOf(el);
    if(~idx) {
      el._listeners(this, 'remove');
      let g = el._$g[0][0];
      g.parentNode.removeChild(g);
      els.splice(idx, 1);
    }
  }

};

module.exports = surface;
