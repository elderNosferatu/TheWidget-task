###*
 * Ідея данного класу полягає в імітації активності на сервері. Якщо вдало підібрати параметри,
 * досягнувши плавних коливань кількості активних користувачів, то й легще буде оцінити дані, що відображає віджет.
 * Це в свою чергу може допомогти з "дезінсекцією", адже за певних умов, зміни можна буде прогнозувати, а не вірити,
 * що розмір чергового стовпчика діаграми правильно відобразився. А те, що він на стільки відрізняється від сусідніх -
 * то всього лиш непередбачений рандом.
 *
 * Також є можливість передавати настройки разом з адресою сайту. Насправді емулятор приймає любу строку в якості адреси,
 * але якщо дотримуватись певних правил, то в строку можна "зашити" будь який із передбачених параметрів.
 * Шифровані дані знаходяться між першою в строці двокрапкою (:) і першим же слешем (/). Таким чином адреса сайту буде
 * нагадувати домен без зазначення протоколу доступу (двійний слеш зіпсує малину) і тим, що мало би бути номером порту.
 * Як раз підстрока на місці порту і є шифрованими параметрами. По суті це масив чисел, записаних у визначеному порядку
 * і розділених дефісами (-). Якщо число в потрібному місці не задане, або воно рівне нулю чи навіть `NaN`, то
 * буде використаних відповідний дефолтний параметр.
 * Порядокс слідування параметрів у наборі визначається масивом `ServerEmulator._CFG_`
 * Слеш в кінці параметрів необхідний, але його вказувати не доведеться адже строка, яку отримує конструктор класу вже
 * буде містити і адресу сайту, і запит, які розділяються слешем.
 *
 * Список параметрів:
 *  - updateDelay (msec) - затримка між спробами обновити данні на сервері;
 *                         не має відношення до частоти запитів на сервері;
 *                         оновлення серверу відбуватиметься навть коли його ніхто не "слухає"
 *
 *  - maxIncome/maxOutcome - максимальна кілкість логінів/логаутів в момент оновлення стану серверу;
 *                           ці параметри як раз і впливають на рандом
 *
 *  - updateChance - шанс, що в відповідний момент сервер зазнає змін; не в кожну ж мить відбуваються зміни,
 *                   інколи можуть бути і стабільні проміжки часу
 *
 *  - maxInitial - ще один рандом-фактор при запуску "сервера" (просто щоб віджети не починали з нуля користувачів)
 *
 *  - responseTime (msec) - просто натяк на те, що дані не приходять моментально
 *
 *
 *
 * Приклад:
 *   1) передаємо: site.com:50-4-3-0.35-125-333
 *      в конструкторі: "site.com:50-4-3-0.35-125-333/activity.script"
 *      параметри: {
 *          updateDelay :   50  // 0.05 sec
 *          maxIncome   :    4  // +4*Math.random()
 *          maxOutcome  :    3  // -3*Math.random()
 *          updateChance: 0.35  // 35%
 *          maxInitial  :  125  // 125*Math.random()
 *          responseTime:  333  // 0.333 sec
 *      }
 *
 *   2) передаємо: veb.log:100-18--1
 *      в конструкторі: "site.com:50-4-3-0.35-125-333/activity.script"
 *      параметри: {
 *          updateDelay :  100  // 0.1 sec
 *          maxIncome   :   18  // +4*Math.random()
 *          updateChance: 1.00  // 100%
 *      }
 *      решта параметрів: дефолтні значення
 ###
class ServerEmulator
	@_CFG_:
		updateDelay: 300
		maxIncome: 20
		maxOutcome: 20
		updateChanse: 0.75
		maxInitial: 100
		responseTime: 100
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
		pointer = -1
		limit = @_PROPS_.length
		while ++pointer < limit
			prop = @_PROPS_[pointer]
			value = parseFloat(data[pointer]) or 0 # because NaN is supervillain ;)
			target["_" + prop] = value or @_CFG_[prop]



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