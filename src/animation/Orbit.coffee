{ANIMATION} = require '../enums'

# 360° in 1000 ms
speedFactor = 2 * Math.PI / 1000

class Orbit
	constructor: ({yawSpeed, pitchSpeed} = {}) ->
		@yawSpeed = yawSpeed || 1
		@pitchSpeed = pitchSpeed || 0

	loop: (controls, diff) ->
		controls.update()
		controls.orbit.delta.yaw = diff * @yawSpeed * speedFactor
		controls.orbit.delta.pitch = diff * @pitchSpeed * speedFactor
		controls.update()
		return stepStatus: ANIMATION.PLAY, usedDiff: diff

module.exports = Orbit
