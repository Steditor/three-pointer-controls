{STATE} = require '../enums'

setState = ->
	switch @touchPoints
		when @config.orbit.touchPoints
			return @state = STATE.ORBIT if @config.orbit.enabled

	return @state = STATE.NONE

onPointerDown = (event) ->
	@touchPoints ?= 0
	@touchPoints++

	setState.call @

	if @state is STATE.NONE
		@start.set undefined, undefined
	else
		@start.set event.clientX, event.clientY

	@startInteraction event
	return

onPointerMove = (event) ->
	unless @start.x and @start.y
		@start.set event.clientX, event.clientY
		return

	switch @state
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

	setState.call @

	@start.set undefined, undefined

	@endInteraction event if @state is STATE.NONE
	return

module.exports = {
	onPointerDown
	onPointerMove
	onPointerUp
}
