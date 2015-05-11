{BUTTON, KEY} = require './enums'

module.exports =
	enabled: true

	dolly:
		enabled: true
		button: BUTTON.MIDDLE
		scale: 1.0
		minDistance: 0
		maxDistance: Infinity

	orbit:
		enabled: true
		button: BUTTON.LEFT
		speed: 1.0
		auto:
			enabled: false
			speed: 2.0
		limits:
			polarMin: 0
			polarMax: Math.PI
			azimuthMin: -Infinity
			azimuthMax: Infinity

	pan:
		enabled: true
		button: BUTTON.RIGHT
		key:
			left: KEY.LEFT
			up: KEY.UP
			right: KEY.RIGHT
			down: KEY.DOWN
			speed: 10.0
