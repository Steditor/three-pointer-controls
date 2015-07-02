{BUTTON, KEY, ANIMATION} = require './enums'

module.exports =
	enabled: true

	dolly:
		enabled: true
		button: BUTTON.MIDDLE
		touchPoints:
			min: 2
			max: 2
		scale: 1.0
		scrollScale: 0.95
		minDistance: 0
		maxDistance: Infinity

	orbit:
		enabled: true
		button: BUTTON.LEFT
		touchPoints:
			min: 1
			max: 1
		speed: 1.0
		minYaw: -Infinity
		maxYaw: Infinity
		minPitch: -Math.PI / 2
		maxPitch: Math.PI / 2

	pan:
		enabled: true
		button: BUTTON.RIGHT
		touchPoints:
			min: 3
			max: 10
		key:
			left: KEY.LEFT
			up: KEY.UP
			right: KEY.RIGHT
			down: KEY.DOWN
			speed: 10.0

	animation:
		enabled: yes
		onInteraction: ANIMATION.STOP
		afterInteraction: ANIMATION.STOP
		loop: yes
