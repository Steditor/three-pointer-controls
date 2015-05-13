# three-pointer-controls

Navigate a three.js scene with [pointer events](http://www.w3.org/TR/pointerevents)

This is an implementation of orbit controls inspired by
[three-orbit-controls](https://www.npmjs.com/package/three-orbit-controls)
but with [pointer events](http://www.w3.org/TR/pointerevents) instead of
mouse events. See [test](#Testing) for an example.

## Usage

[![NPM](https://nodei.co/npm/three-pointer-controls.png)](https://nodei.co/npm/three-pointer-controls/)

```js
PointerControls = require('three-pointer-controls')(THREE)
```

This module exports a function which accepts an instance of THREE, and returns
an OrbitControls class. Use it to control one or several scenes by calling:

```js
controls = new PointerControls()
controls.control(camera)
controls.listenTo(domElement)
```

## Testing

Clone the repository, run `npm install` and `npm test`. Then open
`localhost:9966` to try out three-pointer-controls.
