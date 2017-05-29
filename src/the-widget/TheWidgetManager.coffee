pkg = window.thewidget = window.thewidget or {}


# something like import
ActivityWatchManager = pkg.routine.ActivityWatchManager
InputManager = pkg.routine.InputManager
RegisterManager = pkg.routine.RegisterManager
TheWidget = pkg.TheWidget


###*
 * TheWidgetManager об"єднує в собі весь фонкціонал пакету `thewidget` для обслуговування єкземплярів віджетів
 * Містить в собі набір базових настройок всiх функціональних компонентів, що дозволяє внести глобальні зміни
 * при інстанціфції менеждера.
 *
 * Параметри:
 *   - holderClass,addInstClass - css-класи для маніпуляцій з плейсходерами
 *
 *   - serverUrl - запит до серверів сайтів, які "вміють" працювати з даними віджетами
 *
 *   - storeKey - місце в `localSorage` для збереження даних реєстру
 *
 *   - instUpdClbkName - ім"я методу віджету, який працює з даними активності
 *
 *   - colors - палітра кольорів для діаграм; підібрана як контраст блідому фону і білому тексту
 *
 *   - defaultSite - адреса дефолтного сайту
 *
 *   - requestDelay - задає темп оновлення даних про активність сайту
 *
 *   - limUsers - умовно порогове значення кількості одночасно активних користувачів сайту;
 *                мотивом для вибору конкретного значення може бути як приблизне навантаження,
 *                яке сервер ще здатний гладко перетерпіти, так і візуальний образ для молитв в стилі "дай мені,
 *                боже, хоч `limUsers` активних фоловерів і я обіцяю бути чемним до кінця року!"
 *
 ###
class TheWidgetManager
	_cfg: null
	_cache: null
	_mgrRegister: null
	_mgrInput: null
	_mgrWatch: null


	constructor: (options = null) ->
		@_cfg =
			colors: ["gray", "navy", "green", "olive", "teal", "blue", "purple", "maroon", "red"]
			holderClass: "place_holder"
			addInstClass: "add_the-widget"
			serverUrl: "the-widget.script"
			storeKey: "TheWidget:register"
			instUpdClbkName: "nextData"
			requestDelay: 1e3
			limUsers: 100
			defaultSite: "."
			knownSites: null
		@_cache = {}

		if options?
			for key, value of options
				@_cfg[key] = value


	run: ->
		cfg = @_cfg
		@_mgrRegister = new RegisterManager(cfg.storeKey)
		@_mgrInput = new InputManager(cfg.holderClass, cfg.addInstClass, @_clbInput)
		@_mgrWatch = new ActivityWatchManager(cfg.requestDelay, cfg.serverUrl, @_parseSrvResp, cfg.instUpdClbkName)

		cfg.knownSites = @_mgrWatch.getKnownSites()
		@_mgrRegister.load()
		@_mgrRegister.forEach @_addFromReg


	_addInstance: (holderInstance, holderIndex, instanceData = null) ->
		cfg = @_cfg
		opts = instanceData or {}
		opts.site = opts.site or cfg.defaultSite
		opts.usersLim = opts.usersLim or cfg.limUsers
		unless opts.color?
			opts.barColor = XMath.arrRnd cfg.colors

		theInst = new TheWidget({
			el: holderInstance
			position: holderIndex
			knownSites: cfg.knownSites
			instId: Date.now()
			suicideCallback: @_clbInstSuicide,
			changeCallback: @_clbInstChange
		})
		theInst.setBarColor opts.barColor
		theInst.setUsersLim opts.usersLim
		theInst.setSite opts.site

		@_cache[holderIndex] = theInst
		@_mgrInput.setHolderState holderIndex, true
		@_mgrWatch.subscribe theInst, opts.site
		@_mgrRegister.set holderIndex, opts


	_removeInstance: (instance, holderInstance, holderIndex) ->
		delete @_cache[holderIndex]
		instance.teardown()

		@_mgrInput.setHolderState holderIndex, false
		@_mgrWatch.unsubscribe instance
		@_mgrRegister.set holderIndex, null


	_addFromReg: (holderIndex, instanceData) =>
		holder = @_mgrInput.getHolder holderIndex
		@_addInstance holder, holderIndex, instanceData


	_parseSrvResp: (data) =>
		parseInt(data) or 0


	_clbInput: (holderInstance, holderIndex) =>
		@_addInstance holderInstance, holderIndex
		@_mgrRegister.save()


	_clbInstSuicide: (instance) =>
		holderIndex = instance.position
		holderInstance = @_mgrInput.getHolder holderIndex
		@_removeInstance instance, holderInstance, holderIndex
		@_mgrRegister.save()


	_clbInstChange: (instance) =>
		holderIndex = instance.position
		instanceData = @_mgrRegister.get holderIndex
		instanceData.site = instance.get "site"
		instanceData.usersLim = instance.get "limUsers"
		@_mgrWatch.subscribe instance, instanceData.site
		@_mgrRegister.save()



pkg.TheWidgetManager = TheWidgetManager