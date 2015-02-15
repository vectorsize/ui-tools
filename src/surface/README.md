# Surface

|_API subject to chage._

Emits normalised events from the selected DOM element.

```js

let surface = require('surface')

surface().select('#someDomSelector')

surface.on('drag', (e) => console.log(`mouse position is x:${x}, x:${y}`))
surface.on('mousedown', () => null )
surface.on('mouseup'  , () => null )

```