{ANIMATION} = require '../enums'

class AnimationStep
	reset: ->
		return

	loop: (controls, diff) ->
		return stepStatus: ANIMATION.DONE, usedDiff: diff

module.exports = AnimationStep
