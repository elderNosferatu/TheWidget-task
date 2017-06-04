class XMath
	@rnd: (maximum, minimum = 0) ->
		min = Math.min minimum, maximum
		max = Math.max minimum, maximum

		min + (max - min) * Math.random()


	@intRnd: (maximum, minimum = 0) ->
		Math.round (@rnd maximum, minimum)


	@arrRnd: (array) ->
		if array? and (array.length > 0)
			idx = @intRnd (array.length - 1)
			result = array[idx]

		result



window.XMath = XMath