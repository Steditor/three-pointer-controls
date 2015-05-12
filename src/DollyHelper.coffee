dolly = (controls, distance) ->
	distanceFraction = distance / controls.element.clientHeight
	if distance < 0
		controls.dolly /= (1 - distanceFraction) * controls.config.dolly.scale
	else
		controls.dolly *= (1 + distanceFraction) * controls.config.dolly.scale
	return

scroll = (controls, delta) ->
	if delta < 0
		controls.dolly *= controls.config.dolly.scrollScale
	else
		controls.dolly /= controls.config.dolly.scrollScale

update = (controls) ->
	config = controls.config.dolly
	radius = controls.offset.length() * controls.dolly
	radius = Math.min config.maxDistance, radius
	radius = Math.max config.minDistance, radius
	controls.dolly = 1
	return radius

module.exports =
	dolly: (controls) ->
		return by: ({y}) ->
			if y
				dolly controls, y
			else
				scroll controls, arguments[0]
	update: update
