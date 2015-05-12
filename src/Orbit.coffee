clamp = require 'clamp'

class Orbit
	constructor: (@controls) ->
		@delta =
			yaw: 0
			pitch: 0

		@totalDelta =
			yaw: 0
			pitch: 0

	getConfig: =>
		return @controls.config.orbit

	orbitBy: ({x, y}) =>
		element = @controls.element
		factor = 2 * Math.PI * @getConfig().speed
		@delta.yaw -= factor * x / element.clientWidth
		@delta.pitch -= factor * y / element.clientHeight

	update: (oldOffset) =>
		# rotation around y
		yaw = Math.atan2 oldOffset.x, oldOffset.z
		@delta.yaw = clamp @delta.yaw,
			@getConfig().minYaw - @totalDelta.yaw,
			@getConfig().maxYaw - @totalDelta.yaw
		yaw += @delta.yaw

		# rotation around x'
		zDash = Math.sqrt oldOffset.x * oldOffset.x + oldOffset.z * oldOffset.z
		pitch = Math.atan2 zDash, oldOffset.y
		@delta.pitch = clamp @delta.pitch,
			@getConfig().minPitch - @totalDelta.pitch,
			@getConfig().maxPitch - @totalDelta.pitch
		pitch += @delta.pitch

		@totalDelta.yaw += @delta.yaw
		@totalDelta.pitch += @delta.pitch
		@delta.yaw = 0
		@delta.pitch = 0

		return {
		x: Math.sin(pitch) * Math.sin(yaw)
		y: Math.cos(pitch)
		z: Math.sin(pitch) * Math.cos(yaw)
		}

module.exports = Orbit
