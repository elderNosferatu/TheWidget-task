pkg = window.thewidget = window.thewidget or {}
pkg = pkg.routine = pkg.routine or {}


# Основна ідея класу - інкапсуляція періодичного опитування сервера з можливістю призупинення/відновлення процесу.
# Профітомом використання цього класу є гарантія, що наступний запит не здійсниться до отримання серверної відповіді.
# Однак у попередній версії після відповіді застосовувалась фіксована затримка. Це призводило до розтягування проміжків
# часу між апдейтами. Поточна версія враховує час відповіді сервера, коректуючи фактичну затримку між сусідніми
# запитами. З таким підходом тільки серйозні часові лаги клієнт-серверної комунікації здатні збити темп апдейтів.
class ActivityWatcher
	_url: ""
	_delay: 0
	_callback: null
	_askPtr: -1
	_lastReqTime: 0


	constructor: (@_url, @_delay, @_callback) ->


	awake: ->
		if @_askPtr is -1
			@_askPtr = 0
			@_ask()


	isBusy: () ->
		@_askPtr is -1


	sleep: ->
		clearTimeout @_askPtr
		@_askPtr = -1


	_ask: () =>
		@_lastReqTime = Date.now()
		jQWERTY.post(@_url, @_receive)


	_receive: (data) =>
		@_callback(data, @)

		now = Date.now()
		elapsed = now - @_lastReqTime
		delay = (if elapsed < @_delay then @_delay - elapsed else 0)

		@_askPtr = setTimeout @_ask, delay


pkg.ActivityWatcher = ActivityWatcher