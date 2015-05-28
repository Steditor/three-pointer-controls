clone = require 'clone'
addWheelListener = require 'wheel'

{BUTTON, KEY, STATE} = require './enums'
defaults = require './defaults'

Pan = require './Pan'
Dolly = require './Dolly'
Orbit = require './Orbit'
Animation = require './animation/Animation'

# internally, pointerControls works with +y as up vector
UP = {x: 0, y: 1, z: 0}

module.exports = (THREE) ->
	class PointerControls
		constructor: ->
			@config = clone defaults

			@home =
				target: new THREE.Vector3()
				position: new THREE.Vector3()
				up: new THREE.Vector3()
				upToYp: undefined
				ypToUp: undefined
			@cameras = []
			@target = @home.target.clone()

			@state = STATE.NONE

			@start = new THREE.Vector2()
			@end = new THREE.Vector2()
			@delta = new THREE.Vector2()

			@pan = new Pan @
			@dolly = new Dolly @
			@orbit = new Orbit @
			@animation = new Animation @

			@element = undefined

		control: (camera) =>
			@setHome camera unless @cameras.length
			@cameras.push camera
			@update() # update to enforce limits
			return with: @listenTo

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

			@animation.setStatus @config.animation.onInteraction
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

			@animation.setStatus @config.animation.onInteraction
			@update()
			return

		onPointerUp: (event) =>
			preventDefault event
			@animation.setStatus @config.animation.onInteraction
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

			@home.upToYp = new THREE.Quaternion().setFromUnitVectors @home.up, UP
			@home.ypToUp = @home.upToYp.clone().inverse()

			return

		reset: =>
			@set @home
			return

		set: ({target, position, offset, up}) =>
			@pan.reset()
			@dolly.reset()
			@orbit.reset()
			@updateCamerasTo arguments...
			return

		updateCamerasTo: ({target, position, offset, up}) =>
			@target.copy target if target
			position ?= @target.clone().add offset if offset
			position ?= @cameras[0].position
			up ?= @cameras[0].up

			for camera in @cameras
				camera.position.copy position
				camera.up.copy up
				camera.lookAt @target
			return

		update: =>
			offset = @cameras[0].position.clone().sub @target
			offset.applyQuaternion @home.upToYp
			up = @cameras[0].up.clone()
			up.applyQuaternion @home.upToYp

			target = @pan.update @target
			radius = @dolly.update offset.length()
			{offset: o, up: u} = @orbit.update offset, up
			offset.copy(o).multiplyScalar radius
			up.copy u

			offset.applyQuaternion @home.ypToUp
			up.applyQuaternion @home.ypToUp
			@updateCamerasTo {target, offset, up}
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
