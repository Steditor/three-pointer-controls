buildCanvasApp = require 'canvas-testbed'
require 'PEP'
THREE = require 'three'
PointerControls = require('../')(THREE)

renderer = null
scene = null
camera = null
controls = null

start = (gl, width, height) ->
	renderer = new THREE.WebGLRenderer canvas: gl.canvas
	renderer.setClearColor 0xffffff, 1.0

	scene = new THREE.Scene()

	camera = new THREE.PerspectiveCamera 50, width / height, 1, 1000
	#camera = new THREE.OrthographicCamera 1 / -2, 1 / 2, 1 / 2, 1 / -2, 1, 1000
	camera.position.set 0, 1, -3
	camera.lookAt new THREE.Vector3()

	controls = new PointerControls()
	controls.control camera
	controls.listenTo document

	dummyGeometry = new THREE.BoxGeometry 1, 1, 1
	dummyMaterial = new THREE.MeshBasicMaterial wireframe: true, color: 0x000000
	scene.add new THREE.Mesh dummyGeometry, dummyMaterial

render = (gl, width, height) ->
	renderer.render scene, camera

resize = (width, height) ->
	return unless renderer

	renderer.setViewport 0, 0, width, height
	camera.aspect = width / height
	camera.updateProjectionMatrix()

buildCanvasApp(
	render
	start
	{
		context: 'webgl'
		onResize: resize
	}
)
