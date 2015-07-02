{STATE} = require '../enums'

inInterval = (value, {min, max}) ->
	return min <= value <= max

setState = ->
	if @config.pan.enabled and
	inInterval @touchPoints, @config.pan.touchPoints
		return @state = STATE.PAN
	else if @config.dolly.enabled and
	inInterval @touchPoints, @config.dolly.touchPoints
		return @state = STATE.DOLLY
	else if @config.orbit.enabled and
	inInterval @touchPoints, @config.orbit.touchPoints
		return @state = STATE.ORBIT
	else
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
