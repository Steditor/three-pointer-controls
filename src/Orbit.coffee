clamp = require 'clamp'

class Orbit
	constructor: (@controls) ->
		@delta =
			yaw: 0
			pitch: 0

	getConfig: =>
		return @controls.config.orbit

	orbitBy: ({x, y}) =>
		element = @controls.element
		factor = 2 * Math.PI * @getConfig().speed
		@delta.yaw -= factor * x / element.clientWidth
		@delta.pitch += factor * y / element.clientHeight

	getPoseFrom: (offset, up) ->
		yaw = Math.atan2 offset.x, offset.z # angle in rad relative to +z axis
		yaw += Math.PI if up.y < 0

		zDash = Math.sqrt offset.x * offset.x + offset.z * offset.z
		zDash *= -1 if up.y < 0
		pitch = Math.atan2 offset.y, zDash # angle in rad relative to +z' axis

		return {yaw, pitch}

	update: (oldOffset, oldUp) =>
		{yaw, pitch} = @getPoseFrom oldOffset, oldUp

		@totalDelta ?= {yaw, pitch}

		# rotation around y
		@delta.yaw = clamp @delta.yaw,
			@getConfig().minYaw - @totalDelta.yaw,
			@getConfig().maxYaw - @totalDelta.yaw
		yaw += @delta.yaw
		yaw %= 2 * Math.PI

		# rotation around x'
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
