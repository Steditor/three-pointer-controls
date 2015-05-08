clone = require 'clone'

{BUTTON, KEY, STATE} = require './enums.coffee'
defaults = require './defaults'

module.exports = (THREE) ->
	class PointerControls
		constructor: ->
			@conf = clone defaults

			@state = STATE.NONE
