pkg = window.thewidget = window.thewidget or {}
pkg = pkg.routine = pkg.routine or {}


# something like import
ActivityWatcher = pkg.ActivityWatcher


###*
 * Клас-прослойка між серверами сайтів, віджет-менеджером і езамплярами віджетів на сторінці.
 * Клас гарантує те, що всі віджети, які працюють з одним і тим же сайтом будуть отримувати дані з
 * єдиного джерела. Таким чином знижується навантаження як на трафік, так і на самі сервери сайтів.
 * В принципі достатньо і одного віджета для моніторингу одного сайту, але чим чорт не шутить... В кінці
 * кінців форми для вводу коментарів роблять перед і після блоку коментарів - віключно для зручності.
 *
 * ActivityWatchManager дозволяє інтересантам активності на сайтах оформляти підписку, відміняти чи переоформляти її.
 * Таким чином неслабо розвантажується основний код віджет-менеджера.
 *
 * Також ActivityWatchManager зберігає адреси всіх підключених сайтів, що може допомогти при створенні копій віджетів,
 * які працюють з одним і тим же сайтом - в панелі настройки віджету буде можливість використати адреси відомих сайтів.
 ###
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
				arrSubs.splice idx, 1
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