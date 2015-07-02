{STATE} = require '../enums'

setState = ->
	switch @touchPoints
		when @config.pan.touchPoints
			return @state = STATE.PAN if @config.pan.enabled
		when @config.dolly.touchPoints
			return @state = STATE.DOLLY if @config.dolly.enabled
		when @config.orbit.touchPoints
			return @state = STATE.ORBIT if @config.orbit.enabled

	return @state = STATE.NONE

onPointerDown = (event) ->
	@touchPoints ?= 0
	@touchPoints++

	setState.call @

	if @state is STATE.NONE
		@touchPointerId = undefined
	else
		@touchPointerId = event.pointerId
		@start.set event.clientX, event.clientY

	@startInteraction event
	return

onPointerMove = (event) ->
	unless @touchPointerId?
		@start.set event.clientX, event.clientY
		@touchPointerId = event.pointerId
		return

	return if event.pointerId isnt @touchPointerId

	switch @state
		when STATE.PAN
			@end.set event.clientX, event.clientY
			@delta.subVectors @end, @start
			@pan.panBy @delta
			@start.copy @end
		when STATE.DOLLY
			@end.set event.clientX, event.clientY
			@delta.subVectors @end, @start
			@dolly.dollyBy @delta
			@start.copy @end
		when STATE.ORBIT
			@end.set event.clientX, event.clientY
			@delta.subVectors @end, @start
			@orbit.orbitBy @delta
			@start.copy @end
		else
			return

	@update()
	return

onPointerUp = (event) ->
	@touchPoints--
	@touchPointerId = undefined

	setState.call @

	@endInteraction event if @state is STATE.NONE
	return

module.exports = {
	onPointerDown
	onPointerMove
	onPointerUp
}
