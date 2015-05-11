dolly = (controls, distance) ->
	distanceFraction = distance / controls.element.clientHeight
	if distance < 0
		controls.dolly /= (1 - distanceFraction) * controls.config.dolly.scale
	else
		controls.dolly *= (1 + distanceFraction) * controls.config.dolly.scale
	return

module.exports = dolly: (controls) ->
	return by: ({y}) -> dolly controls, y
