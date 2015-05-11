module.exports =
	UNKNOWN: 0
	PERSPECTIVE: 1
	ORTHOGRAPHIC: 2
	of: (camera) ->
		return module.exports.UNKNOWN unless camera.type?
		switch camera.type
			when 'PerspectiveCamera'
				return module.exports.PERSPECTIVE
			when 'OrthographicCamera'
				return module.exports.ORTHOGRAPHIC
			else
				return module.exports.UNKNOWN
