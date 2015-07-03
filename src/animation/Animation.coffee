{ANIMATION} = require './../enums'

Orbit = require './Orbit'

class Animation
	constructor: (@controls) ->
		@clear()
		@reset()

	clear: =>
		@steps = []
		return

	reset: =>
		@step = 0
		@status = ANIMATION.STOP

	pauseIfNotEnabled: =>
		unless @controls.config.enabled and @controls.config.animation.enabled
			@pause()
		return @status

	play: =>
		return if @status is ANIMATION.PLAY

		@lastLoop = null
		@status = ANIMATION.PLAY

		requestAnimationFrame @_loop

	pause: =>
		@status = ANIMATION.PAUSE

	stop: =>
		@steps[@step]?.reset()
		@step = 0
		@status = ANIMATION.STOP

	setStatus: (status) =>
		switch status
			when ANIMATION.PLAY
				@play()
			when ANIMATION.PAUSE
				@pause()
			when ANIMATION.STOP
				@stop()

	_loop: (timestamp) =>
		@pauseIfNotEnabled()
		return unless @status is ANIMATION.PLAY

		@lastLoop ?= timestamp
		diff = timestamp - @lastLoop

		while diff > 0 and @status is ANIMATION.PLAY
			diff -= @_runStep diff

		@lastLoop = timestamp
		requestAnimationFrame @_loop

	_runStep: (diff) =>
		unless @steps[@step]?
			if @controls.config.animation.loop and @step > 0
				@step = 0
			else
				@status = ANIMATION.DONE
				return 0

		{stepStatus, usedDiff} = @steps[@step].loop @controls, diff
		if stepStatus is ANIMATION.DONE
			@steps[@step].reset()
			@step++
		return usedDiff

	orbit: (options) =>
		@steps.push new Orbit options
		@play()

module.exports = Animation
