class jQWERTY
	@post: (url, success) ->
		setTimeout(
			->
				success(serverEmulator.usersAmount)
				return
			Math.random 333
		)
		return



class ServerEmulator
	_updRate: 300
	_updPtr: -1
	_maxIncome: 20
	_maxOutcome: 20
	_changeChance: 0.75
	usersAmount: 0


	run: ->
		@_updPtr = setInterval(
			=>
				if Math.random() < @_changeChance
					@update()
			@_updRate
		)
		return

	die: ->
		clearInterval @_updPtr
		return

	update: =>
		income = Math.random() * @_maxIncome
		outcome = Math.random() * @_maxOutcome
		change = Math.round(income - outcome)
		@usersAmount += change
		if @usersAmount < 0 then @usersAmount = 0

		return

window.jQWERTY = jQWERTY
window.serverEmulator = new ServerEmulator()
