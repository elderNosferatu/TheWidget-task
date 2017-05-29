pkg = window.thewidget = window.thewidget or {}
pkg = pkg.routine = pkg.routine or {}


###*
 Реєстр активних віджетів. Дозволяє, при доступності localStorage, зберігати і завантажуват власну інформацію
 ###
class RegisterManager
	_storeKey = null
	_data = null


	constructor: (@_storeKey) ->
		@_data = {}

	load: ->
		try
			temp = localStorage.getItem @_storeKey
			temp = JSON.parse temp
		catch error
			null # Just a trick for WebStorm's code folding

		@_data = temp or {}


	save: ->
		try
			temp = JSON.stringify @_data
			localStorage.setItem @_storeKey, temp
		catch error
			null # Just a trick for WebStorm's code folding


	get: (key) ->
		@_data[key]


	set: (key, value) ->
		if value?
			@_data[key] = value
		else
			delete @_data[key]


	forEach: (callback) ->
		if callback?
			for key, value of @_data
				callback.call null, key, value



pkg.RegisterManager = RegisterManager