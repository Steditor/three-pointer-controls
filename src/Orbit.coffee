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
		@delta.pitch += factor * y / element.clientHeight

	update: (oldOffset, oldUp) =>
		# rotation around y
		yaw = Math.atan2 oldOffset.x, oldOffset.z # angle in rad relative to +z axis
		@delta.yaw = clamp @delta.yaw,
			@getConfig().minYaw - @totalDelta.yaw,
			@getConfig().maxYaw - @totalDelta.yaw
		if oldUp.y < 0
			yaw += Math.PI
		yaw += @delta.yaw
		yaw %= 2 * Math.PI

		# rotation around x'
		zDash = Math.sqrt oldOffset.x * oldOffset.x + oldOffset.z * oldOffset.z
		if oldUp.y < 0
			zDash *= -1
		pitch = Math.atan2 oldOffset.y, zDash # angle in rad relative to +z' axis
		@delta.pitch = clamp @delta.pitch,
			@getConfig().minPitch - @totalDelta.pitch,
			@getConfig().maxPitch - @totalDelta.pitch
		pitch += @delta.pitch
		pitch += Math.PI
		pitch %= 2 * Math.PI
		pitch -= Math.PI

		@totalDelta.yaw += @delta.yaw
		@totalDelta.pitch += @delta.pitch
		@delta.yaw = 0
		@delta.pitch = 0

		if pitch < -Math.PI / 2 or pitch > Math.PI / 2
			up = x: 0, y: -1, z: 0
		else
			up = x: 0, y: 1, z: 0

		return {
			offset:
				x: Math.cos(pitch) * Math.sin(yaw)
				y: Math.sin(pitch)
				z: Math.cos(pitch) * Math.cos(yaw)
			up
		}

module.exports = Orbit
