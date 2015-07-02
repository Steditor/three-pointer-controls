{STATE} = require '../enums'

inInterval = (touchPoints, {min, max}) ->
	return min <= Object.keys(touchPoints).length <= max

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
	@touchPoints ?= {}
	@touchPoints[event.pointerId] ?= @start.clone()
	@touchPoints[event.pointerId].set event.clientX, event.clientY

	setState.call @

	@startInteraction event
	return

onPointerMove = (event) ->
	@start.copy @touchPoints[event.pointerId]
	@touchPoints[event.pointerId].set event.clientX, event.clientY
	@end.copy @touchPoints[event.pointerId]

	switch @state
		when STATE.PAN
			return if String(event.pointerId) isnt Object.keys(@touchPoints)[0]
			@delta.subVectors @end, @start
			@pan.panBy @delta

		when STATE.DOLLY
			if String(event.pointerId) is Object.keys(@touchPoints)[0]
				other = @touchPoints[Object.keys(@touchPoints)[1]]
			else
				other = @touchPoints[Object.keys(@touchPoints)[0]]

			oldDistance = other.distanceTo @start
			newDistance = other.distanceTo @end

			@dolly.dollyBy y: oldDistance - newDistance

		when STATE.ORBIT
			return if String(event.pointerId) isnt Object.keys(@touchPoints)[0]
			@delta.subVectors @end, @start
			@orbit.orbitBy @delta
		else
			return

	@update()
	return

onPointerUp = (event) ->
	delete @touchPoints[event.pointerId]

	setState.call @

	@endInteraction event if @state is STATE.NONE
	return

module.exports = {
	onPointerDown
	onPointerMove
	onPointerUp
}
