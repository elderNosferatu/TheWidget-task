pkg = window.thewidget = window.thewidget or {}
pkg = pkg.routine = pkg.routine or {}


# something like import
ActivityWatcher = pkg.ActivityWatcher


class ActivityWatchManager
	_cache: null
	_cfg: null


	constructor: (delay, serverUrl, fnParser, subsClbName) ->
		@_cache =
			watch2subs: new Dictionary()
			subs2watch: new Dictionary()
			site2watch: new Dictionary()
		@_cfg =
			delay      : delay or 0
			serverUrl  : serverUrl or ""
			fnParser   : fnParser
			subsClbName: subsClbName or ""


	getKnownSites: ->
		@_cache.site2watch.keys false


	subscribe: (subscriber, site) ->
		if subscriber?
			@unsubscribe subscriber

			watcher = @_getWatcher site
			arrSubs = @_cache.watch2subs.get watcher
			arrSubs.push subscriber
			@_cache.subs2watch.set subscriber, watcher
			if arrSubs.length > 0
				watcher.awake()


	unsubscribe: (subscriber) ->
		watcher = @_cache.subs2watch.get subscriber
		@_cache.subs2watch.del subscriber

		if subscriber? and watcher?
			arrSubs = @_cache.watch2subs.get watcher
			idx = arrSubs.indexOf subscriber
			if idx isnt -1
				arrSubs.splice idx, -1
			if arrSubs.length is 0
				watcher.sleep()


	_getWatcher: (site) ->
		watcher = @_cache.site2watch.get site
		unless watcher?
			url = site + "/" + @_cfg.serverUrl
			watcher = new ActivityWatcher(url, @_cfg.delay, @_watchCallback)
			@_cache.site2watch.set site, watcher
			@_cache.watch2subs.set watcher, []

		watcher

	_watchCallback: (data, watcher) =>
		arrSubs = @_cache.watch2subs.get watcher
		parser = @_cfg.fnParser
		info = (if parser? then parser.call null, data else data)
		clbName = @_cfg.subsClbName

		for subs in arrSubs
			subs[clbName].call subs, info


pkg.ActivityWatchManager = ActivityWatchManager


###
class ActivityMgr
	_url: null
	_delay: 0
	_fnParser: null
	_subsClbName: null

	_watcher: new ActivityWatcher()
	_subscribers: []

	##*
   * @class ActivityManager
   * @param {string}  url  url, по якому можна отримати інфу про активність на сайті
   * @param {number}  delay  затримка між запитами про активність
   * @param {function|null}  fnParser функція перетворення серверних даних. Якщо не задана, то підписчики отримуватимуть дані в сирому виді
   * @param {string|null}  subsClbName  ім"я колбек-методу підписчика; якщо аргумент невизначений, або є порожнтою строкою, або у підписчика немає методу з таким іменем, то сам підписчик вважається колбек-функцією
   * @param {any} subscribers можливий набір бажаючих підписатись на інформацію про активність із вказаного url
	 ##
	constructor: (@_url, @_delay, @_fnParser, @_subsClbName, subscribers...) ->
		@_watcher = new ActivityWatcher(@_url, @_delay, @_clbWatch)

		if subscribers? and subscribers.length > 0
			for asubs in subscribers
				if asubs?
					@addSubscriber(asubs)


	addSubscriber: (instance) ->
		if instance? and (-1 isnt @_subscribers.indexOf instance)
			@_subscribers.push instance
			if not @_watcher.isBusy()
				@_watcher.awake()


	removeSubscriber: (instance) ->
		idx = @_subscribers.indexOf instance
		if idx isnt -1
			@_subscribers.splice idx, 1
			if @_subscribers.length is 0
				@_watcher.sleep()


	_clbWatch: (data) =>
		info = (if @_fnParser? then @_fnParser.call null, data else data)
		for subs in @_subscribers
			method = subs[@_subsClbName] or subs
			scope = (if method is subs then null else subs)
			method.call scope, info
		# З усіх сил стримуюсь не вставити в послідній рядок оператор `return` (див. розділ "Запитання" в файлі $proj$/Read.me)


pkg.ActivityManager = ActivityManager
###