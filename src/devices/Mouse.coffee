{STATE} = require '../enums'

onPointerDown = (event) ->
	switch event.buttons
		when @config.pan.button
			return unless @config.pan.enabled
			@state = STATE.PAN
			@start.set event.clientX, event.clientY
		when @config.dolly.button
			return unless @config.dolly.enabled
			@state = STATE.DOLLY
			@start.set event.clientX, event.clientY
		when @config.orbit.button
			return unless @config.orbit.enabled
			@state = STATE.ORBIT
			@start.set event.clientX, event.clientY
		else
			return

	@startInteraction event
	return

onPointerMove = (event) ->
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
	@state = STATE.NONE
	@endInteraction event
	return

onMouseWheel = (event) ->
	return unless @config.dolly.enabled and @config.dolly.mouseWheelEnabled

	@dolly.scrollBy event.deltaY
	@update()

module.exports = {
	onPointerDown
	onPointerMove
	onPointerUp
	onMouseWheel
}
