orbit = (controls, deltaX, deltaY) ->
	element = controls.element
	factor = 2 * Math.PI * controls.config.orbit.speed
	orbitLeft controls, factor * deltaX / element.clientWidth
	orbitUp controls, factor * deltaY / element.clientHeight

orbitLeft = (controls, angle) ->
	controls.yawDelta -= angle

orbitUp = (controls, angle) ->
	controls.pitchDelta -= angle

update = (controls) ->
	config = controls.config.orbit
	offset = controls.offset

	# rotation around y
	yaw = Math.atan2 offset.x, offset.z
	yawDelta = controls.yawDelta
	yawDelta = Math.min config.maxYaw - controls.totalYawDelta, yawDelta
	yawDelta = Math.max config.minYaw - controls.totalYawDelta, yawDelta
	controls.totalYawDelta += controls.yawDelta
	yaw += yawDelta

	# rotation around x'
	zDash = Math.sqrt offset.x * offset.x + offset.z * offset.z
	pitch = Math.atan2 zDash, offset.y
	pitchDelta = controls.pitchDelta
	pitchDelta = Math.min config.maxPitch - controls.totalPitchDelta, pitchDelta
	pitchDelta = Math.max config.minPitch - controls.totalPitchDelta, pitchDelta
	controls.totalPitchDelta += pitchDelta
	pitch += pitchDelta

	controls.yawDelta = 0
	controls.pitchDelta = 0

	return {yaw, pitch}

module.exports =
	orbit: (controls) ->
		return by: ({x, y}) -> orbit controls, x, y
	update: update
