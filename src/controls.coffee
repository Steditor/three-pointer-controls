clone = require 'clone'
addWheelListener = require 'wheel'

{BUTTON, KEY, STATE} = require './enums'
defaults = require './defaults'

PanHelper = require './PanHelper'
DollyHelper = require './DollyHelper'
OrbitHelper = require './OrbitHelper'

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

			@pan = new THREE.Vector3()
			@dolly = 1
			@phiDelta = 0
			@thetaDelta = 0

			@element = undefined

		control: (camera) =>
			@cameras.push camera
			return

		listenTo: (domElement) =>
			registerEventListeners @, domElement
			return

		onPointerDown: (event) =>
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
					DollyHelper.dolly(this).by @delta
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
			DollyHelper.dolly(this).by event.deltaY
			@update()
			return

		update: =>
			@offset.copy(@cameras[0].position).sub @target

			radius = @offset.length() * @dolly

			# rotation around y
			phi = Math.atan2 @offset.x, @offset.z
			phi += @phiDelta

			# rotation around x'
			zDash = Math.sqrt @offset.x * @offset.x + @offset.z * @offset.z
			theta = Math.atan2 zDash, @offset.y
			theta += @thetaDelta

			@target.add @pan
			@offset.x = radius * Math.sin(theta) * Math.sin(phi)
			@offset.y = radius * Math.cos(theta)
			@offset.z = radius * Math.sin(theta) * Math.cos(phi)

			@pan.set 0, 0, 0
			@dolly = 1
			@phiDelta = 0
			@thetaDelta = 0

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
