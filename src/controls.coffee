clone = require 'clone'
addWheelListener = require 'wheel'

{BUTTON, KEY, STATE} = require './enums'
defaults = require './defaults'

PanHelper = require './Pan'
Dolly = require './Dolly'
OrbitHelper = require './Orbit'

module.exports = (THREE) ->
	class PointerControls
		constructor: ->
			@config = clone defaults

			@cameras = []
			@target = new THREE.Vector3()
			@state = STATE.NONE

			@start = new THREE.Vector2()
			@end = new THREE.Vector2()
			@delta = new THREE.Vector2()
			@offset = new THREE.Vector3()

			@panDelta = new THREE.Vector3()
			@dolly = new Dolly @
			@yawDelta = 0
			@pitchDelta = 0

			@totalYawDelta = 0
			@totalPitchDelta = 0

			@element = undefined

		control: (camera) =>
			@cameras.push camera
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
					PanHelper.pan(this).by @delta
					@start.copy @end
				when STATE.DOLLY
					@end.set event.clientX, event.clientY
					@delta.subVectors @end, @start
					@dolly.dollyBy @delta
					@start.copy @end
				when STATE.ORBIT
					@end.set event.clientX, event.clientY
					@delta.subVectors @end, @start
					OrbitHelper.orbit(this).by @delta
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

		update: =>
			@offset.copy(@cameras[0].position).sub @target

			PanHelper.update this
			radius = @dolly.update @offset
			{yaw, pitch} = OrbitHelper.update this

			@offset.x = radius * Math.sin(pitch) * Math.sin(yaw)
			@offset.y = radius * Math.cos(pitch)
			@offset.z = radius * Math.sin(pitch) * Math.cos(yaw)

			for camera in @cameras
				camera.position.copy(@target).add @offset
				camera.lookAt @target
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
