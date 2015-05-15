buildCanvasApp = require 'canvas-testbed'
require 'PEP'
THREE = require 'three'
PointerControls = require('../')(THREE)

renderer = null
scene = null
camera = null
controls = null

addCube = (scene) ->
	dummyGeometry = new THREE.BoxGeometry 1, 1.5, 2
	dummyMaterial = new THREE.MeshBasicMaterial wireframe: true, color: 0x000000
	scene.add new THREE.Mesh dummyGeometry, dummyMaterial

addAxis = (scene, color, point2) ->
	geometryAxis = new THREE.Geometry()
	geometryAxis.vertices.push new THREE.Vector3 0, 0, 0
	geometryAxis.vertices.push point2
	materialAxis = new THREE.LineBasicMaterial color: color, linewidth: 2
	axis = new THREE.Line geometryAxis, materialAxis
	scene.add axis

start = (gl, width, height) ->
	renderer = new THREE.WebGLRenderer canvas: gl.canvas
	renderer.setClearColor 0xffffff, 1.0

	scene = new THREE.Scene()

	camera = new THREE.PerspectiveCamera 50, width / height, 1, 1000
	#camera = new THREE.OrthographicCamera 1 / -2, 1 / 2, 1 / 2, 1 / -2, 1, 1000
	camera.position.set 0, 1, 3
	camera.up.set 0, 1, 0
	camera.lookAt new THREE.Vector3()

	controls = new PointerControls()
	controls.control(camera).with(document)

	#addCube scene
	addAxis scene, 0xff0000, new THREE.Vector3 1, 0, 0
	addAxis scene, 0x00ff00, new THREE.Vector3 0, 1, 0
	addAxis scene, 0x0000ff, new THREE.Vector3 0, 0, 1

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
