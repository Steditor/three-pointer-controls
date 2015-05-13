clamp = require 'clamp'

class Dolly
	constructor: (@controls) ->
		@reset()

	reset: =>
		@dolly = 1

	getConfig: =>
		return @controls.config.dolly

	dollyBy: ({y}) =>
		distanceFraction = y / @controls.element.clientHeight
		if y < 0
			@dolly /= (1 - distanceFraction) * @getConfig().scale
		else
			@dolly *= (1 + distanceFraction) * @getConfig().scale
		return

	scrollBy: (delta) =>
		if delta < 0
			@dolly *= @getConfig().scrollScale
		else
			@dolly /= @getConfig().scrollScale

	update: (oldRadius) =>
		radius = oldRadius * @dolly
		radius = clamp radius, @getConfig().minDistance, @getConfig().maxDistance
		@dolly = 1
		return radius

module.exports = Dolly
