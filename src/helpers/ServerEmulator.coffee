###*
 * 
###
class ServerEmulator
	@_CFG_:
		maxInitial: 100
		maxIncome: 20
		maxOutcome: 20
		updateDelay: 300
		responseTime: 100
		updateChanse: 0.75
	@_PROPS_: [
		"updateDelay"
		"maxIncome"
		"maxOutcome"
		"updateChanse"
		"maxInitial"
		"responseTime"
	]

	@parseUrl: (url) ->
		# domain:config/request
		# example.org:-%updateDelay%-%maxIncome%-%maxOutcome%-%updateChance%-%maxInitialAmount%-%responseTime%/%acrivityRequest.script%
		# sub.my_site.com:-500-15-17-0.9125-50-999/the-widget/activity.php
		# - updateDelay  == 500 (0.5sec)
		# - maxIncome    == 15
		# - maxOutcome   == 17
		# - updateChance == 0.9125 (91.25%)
		# - maxInitial   == 50
		# - responseTime == 999 (0.999sec)
		from = 1 + url.indexOf ":"
		to = url.indexOf "/"
		hasCfg = (from isnt 0) and (from < to)
		if hasCfg
			str = url.substring from, to
			arr = str.split("-")

		arr or []


	@applyConfig: (data, target) ->
		for prop in @_PROPS_
			val = parseFloat(data[prop]) or 0 # because NaN is supervillain ;)
			target["_#{prop}"] = val or @_CFG_[prop]



	_url: null
	_updPtr: 0

	_maxInitial: 0
	_maxIncome: 0
	_maxOutcome: 0
	_responseTime: 0
	_updateChanse: 0
	_updateDelay: 0

	usersAmount: 0


	constructor: (url) ->
		@_url = url
		cfg = ServerEmulator.parseUrl url
		ServerEmulator.applyConfig cfg, @
		@_run()


	die: -> # whatever


	_run: ->
		@usersAmount = XMath.rnd(@_maxInitial)
		@_updPtr = setInterval(
			=> if Math.random() < @_updateChanse then @_update()
			@_responseTime
		)


	_update: =>
		income = XMath.rnd @_maxIncome
		outcome = XMath.rnd @_maxOutcome
		change = Math.round income - outcome
		@usersAmount += change
		if @usersAmount < 0
			@usersAmount = 0



window.ServerEmulator = ServerEmulator