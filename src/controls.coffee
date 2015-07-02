clone = require 'clone'
addWheelListener = require 'wheel'

{BUTTON, KEY, STATE} = require './enums'
defaults = require './defaults'

Pan = require './Pan'
Dolly = require './Dolly'
Orbit = require './Orbit'
Animation = require './animation/Animation'

Mouse = require './devices/Mouse'
Touch = require './devices/Touch'

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

		getDeviceFor: (event) =>
			switch event.pointerType
				when 'touch'
					return Touch
				when 'mouse'
					return Mouse
				when 'pen'
					# Try to handle pens like mice for the moment
					return Mouse

		onPointerDown: (event) =>
			return unless @config.enabled
			preventDefault event

			Device = @getDeviceFor event
			Device.onPointerDown.call @, event
			return

		onPointerMove: (event) =>
			return unless @config.enabled
			preventDefault event

			Device = @getDeviceFor event
			Device.onPointerMove.call @, event
			return

		onPointerUp: (event) =>
			return unless @config.enabled
			preventDefault event

			Device = @getDeviceFor event
			Device.onPointerUp.call @, event
			return

		onMouseWheel: (event) =>
			return unless @config.enabled
			preventDefault event

			Mouse.onMouseWheel.call @, event
			return

		startInteraction: (event) =>
			@animation.setStatus @config.animation.onInteraction
			@element = event.target
			document.addEventListener 'pointermove', @onPointerMove
			document.addEventListener 'pointerup', @onPointerUp
			return

		endInteraction: (event) =>
			@animation.setStatus @config.animation.afterInteraction
			@element = undefined
			document.removeEventListener 'pointermove', @onPointerMove
			document.removeEventListener 'pointerup', @onPointerUp
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
