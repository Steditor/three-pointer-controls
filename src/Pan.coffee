CameraType = require './CameraType'

class Pan
	constructor: (@controls) ->
		@reset()

	reset: =>
		@delta =
			x: 0
			y: 0
			z: 0

	panBy: ({x, y}) =>
		switch CameraType.of @controls.cameras[0]
			when CameraType.PERSPECTIVE
				@perspectivePanBy x, y
			when CameraType.ORTHOGRAPHIC
				@orthographicPanBy x, y
			else
				console.warn 'Camera type not supported'
		return

	perspectivePanBy: (x, y) =>
		camera = @controls.cameras[0]
		position = camera.position
		offset = position.clone().sub @controls.target
		targetDistance = offset.length()

		targetDistance *= Math.tan camera.fov / 2 * Math.PI / 180

		# Perspective camera is only fixed to screen height
		element = @controls.element
		@panLeft 2 * x * targetDistance / element.clientHeight
		@panUp 2 * y * targetDistance / element.clientHeight
		return

	orthographicPanBy: (x, y) =>
		camera = @controls.cameras[0]
		element = @controls.element
		@panLeft x * (camera.right - camera.left) / element.clientWidth
		@panUp y * (camera.top - camera.bottom) / element.clientHeight
		return

	panLeft: (distance) =>
		me = @controls.cameras[0].matrix.elements
		# x column of matrix
		@delta.x -= me[0] * distance
		@delta.y -= me[1] * distance
		@delta.z -= me[2] * distance
		return

	panUp: (distance) =>
		me = @controls.cameras[0].matrix.elements
		# y column of matrix
		@delta.x += me[4] * distance
		@delta.y += me[5] * distance
		@delta.z += me[6] * distance
		return

	update: ({x, y, z}) =>
		x += @delta.x
		y += @delta.y
		z += @delta.z
		@delta.x = 0
		@delta.y = 0
		@delta.z = 0
		return {x, y, z}

module.exports = Pan
