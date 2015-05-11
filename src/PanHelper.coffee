CameraType = require './CameraType'

pan = (controls, direction, distance) ->
	controls.pan.add direction.multiplyScalar distance
	return

panLeft = (controls, distance) ->
	me = controls.cameras[0].matrix.elements
	# x column of matrix
	controls.offset.set me[0], me[1], me[2]
	pan controls, controls.offset, -distance
	return

panUp = (controls, distance) ->
	me = controls.cameras[0].matrix.elements
	# y column of matrix
	controls.offset.set me[4], me[5], me[6]
	pan controls, controls.offset, distance
	return

perspectivePan = (controls, deltaX, deltaY) ->
	camera = controls.cameras[0]
	position = camera.position
	offset = position.clone().sub controls.target
	targetDistance = offset.length()

	targetDistance *= Math.tan camera.fov / 2 * Math.PI / 180

	# Perspective camera is only fixed to screen height
	element = controls.element
	panLeft controls, 2 * deltaX * targetDistance / element.clientHeight
	panUp controls, 2 * deltaY * targetDistance / element.clientHeight
	return

orthographicPan = (controls, deltaX, deltaY) ->
	camera = controls.cameras[0]
	element = controls.element
	panLeft controls, deltaX * (camera.right - camera.left) / element.clientWidth
	panUp controls, deltaY * (camera.top - camera.bottom) / element.clientHeight
	return

selectPanFunction = (camera) ->
	switch CameraType.of camera
		when CameraType.PERSPECTIVE
			return perspectivePan
		when CameraType.ORTHOGRAPHIC
			return orthographicPan
		else
			console.warn 'Camera type not supported'
			return undefined

module.exports = pan: (controls) ->
	panFunction = selectPanFunction controls.cameras[0]
	return undefined unless panFunction

	return by: ({x, y}) -> panFunction controls, x, y
