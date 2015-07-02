{STATE} = require '../enums'

onPointerDown = (event) ->
	@touchPoints ?= 0
	@touchPoints++

	switch @touchPoints
		when @config.orbit.touch
			@state = STATE.ORBIT
			@start.set event.clientX, event.clientY
		else
			@state = STATE.NONE
			@start.set undefined, undefined

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

	switch @touchPoints
		when @config.orbit.touch
			@state = STATE.ORBIT
		else
			@state = STATE.NONE

	@start.set undefined, undefined

	@endInteraction event if @state is STATE.NONE
	return

module.exports = {
	onPointerDown
	onPointerMove
	onPointerUp
}
