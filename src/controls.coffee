clone = require 'clone'

{BUTTON, KEY, STATE} = require './enums.coffee'
defaults = require './defaults'

module.exports = (THREE) ->
	class PointerControls
		constructor: ->
			@conf = clone defaults

			@state = STATE.NONE

			@element = undefined

		onPointerDown: (event) =>
			preventDefault event

			return if @state is STATE.NONE

			@element = event.target
			document.addEventListener 'pointermove', @onPointerMove
			document.addEventListener 'pointerup', @onPointerUp
			return

		onPointerMove: (event) =>
			preventDefault event
			return

		onPointerUp: (event) =>
			preventDefault event
			document.removeEventListener 'pointermove', @onPointerMove
			document.removeEventListener 'pointerup', @onPointerUp
			@element = undefined
			return

preventDefault = (event) ->
	event.preventDefault()
	event.stopPropagation()
	event.stopImmediatePropagation()
	return

registerEventListeners = (controls, domElement) ->
	domElement.addEventListener 'contextmenu', preventDefault
	domElement.addEventListener 'pointerdown', controls.onPointerDown
