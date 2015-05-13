clone = require 'clone'
addWheelListener = require 'wheel'

{BUTTON, KEY, STATE} = require './enums'
defaults = require './defaults'

Pan = require './Pan'
Dolly = require './Dolly'
Orbit = require './Orbit'

module.exports = (THREE) ->
	class PointerControls
		constructor: ->
			@config = clone defaults

			@home =
				target: new THREE.Vector3()
				position: undefined
				up: undefined
			@cameras = []
			@target = @home.target.clone()

			@state = STATE.NONE

			@start = new THREE.Vector2()
			@end = new THREE.Vector2()
			@delta = new THREE.Vector2()
			@offset = new THREE.Vector3()

			@pan = new Pan @
			@dolly = new Dolly @
			@orbit = new Orbit @

			@element = undefined

		control: (camera) =>
			@cameras.push camera
			@home.position ?= camera.position.clone()
			@home.up ?= camera.up
			@update() # update to enforce limits
			return

		listenTo: (domElement) =>
			registerEventListeners @, domElement
			return

		onPointerDown: (event) =>
			return unless @config.enabled
			preventDefault event

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

			@element = event.target
			document.addEventListener 'pointermove', @onPointerMove
			document.addEventListener 'pointerup', @onPointerUp
			return

		onPointerMove: (event) =>
			preventDefault event

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

		onPointerUp: (event) =>
			preventDefault event
			document.removeEventListener 'pointermove', @onPointerMove
			document.removeEventListener 'pointerup', @onPointerUp
			@element = undefined
			@state = STATE.NONE
			return

		onMouseWheel: (event) =>
			preventDefault event
			@dolly.scrollBy event.deltaY
			@update()
			return

		setHome: ({target, position, up}) =>
			@home.target.copy target if target
			@home.position.copy position if position
			@home.up.copy up if up

		updateCamerasTo: ({target, position, up}) =>
			target ?= @target
			position ?= @cameras[0].position
			up ?= @cameras[0].up
			for camera in @cameras
				camera.position.copy position
				camera.up.copy up
				camera.lookAt target
			return

		update: =>
			@offset.copy(@cameras[0].position).sub @target

			@target.copy @pan.update @target
			newRadius = @dolly.update @offset.length()
			newOrbit = @orbit.update @offset, @cameras[0].up
			@offset
				.copy newOrbit.offset
				.multiplyScalar newRadius
			position = @target.clone().add @offset

			@updateCamerasTo {@target, position, up: newOrbit.up}
			return

preventDefault = (event) ->
	event.preventDefault()
	event.stopPropagation()
	event.stopImmediatePropagation()
	return

registerEventListeners = (controls, domElement) ->
	domElement.addEventListener 'contextmenu', preventDefault
	domElement.addEventListener 'pointerdown', controls.onPointerDown
	addWheelListener domElement, controls.onMouseWheel
	return
