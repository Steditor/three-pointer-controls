orbit = (controls, deltaX, deltaY) ->
	element = controls.element
	factor = 2 * Math.PI * controls.config.orbit.speed
	orbitLeft controls, factor * deltaX / element.clientWidth
	orbitUp controls, factor * deltaY / element.clientHeight

orbitLeft = (controls, angle) ->
	controls.phiDelta -= angle

orbitUp = (controls, angle) ->
	controls.thetaDelta -= angle

module.exports = orbit: (controls) ->
	return by: ({x, y}) -> orbit controls, x, y
