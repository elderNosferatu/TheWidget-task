### Manager ###
class TheWidgetMnager
	@_CFG_:
		holderClass: "place_holder"
		addInstClass: "add_the-widget"
		serverUrl: "the-widget.script"
		storeKey: "TheWidget:register"
		colors: ["gray", "navy", "green", "olive", "teal", "blue", "purple", "maroon", "red"]
		requestDelay: 1e3
		limUsers: 100
		defaultSite: "www.it-is-a-stub-for-tests.testsite"

	@_cache:
		instances: []

	@_holders: []
	@_register: {}
	@_watcher: null


	@run: ->
		watchUrl = @_CFG_.defaultSite + "/" + @_CFG_.serverUrl
		@_watcher = new ActivityWatcher(watchUrl, @_CFG_.requestDelay, @_watchCallback)
		@_watcher.sleep()

		temp = $("." + @_CFG_.holderClass) # TODO: try interpolation
		for i in [0...temp.length]
			holder = @_holders[i] = temp[i]
			$(holder).on "mouseover click", @_handleMouse

		regData = @_loadRegister()
		@_parseRegData regData
		return

	# TODO:
	@stop: (clearStore) ->
		clearStore
		return

	@_getIndex: (holderInst) ->
		@_holders.indexOf holderInst

	@_isBusy: (holderInstOrIdx) ->
		isId = "number" is typeof holderInstOrIdx
		if isId is yes
			id = holderInstOrIdx
		else
			id = @_getIndex holderInstOrIdx
		(@_register[id])?

	@_addInstanceAt: (holderIndex, instanceData = null, silence = false) ->
		holder = @_holders[holderIndex]

		if holder?
			opts = instanceData or {}
			opts.site = opts.site or @_CFG_.defaultSite
			opts.usersLim = @_CFG_.limUsers
			unless opts.barColor?
				ci = Math.floor( Math.random() * @_CFG_.colors.length )
				opts.barColor = @_CFG_.colors[ci]

			theInst = new TheWidget({ el: holder, instId: Date.now(), suicideCallback: @_instSuicideCallback })
			theInst.setBarColor opts.barColor
			theInst.setUsersLim opts.usersLim
			theInst.set "site", opts.site

			@_register[holderIndex] = opts
			@_cache.instances[holderIndex] = theInst
			@_watcher.awake()

			if not silence then @_saveRegister()

		return

	@_removeInstanceAt: (holderIndex) ->
		instance = @_cache.instances[holderIndex]
		holder = @_holders[holderIndex]
		if instance? and holder?
			delete @_cache.instances[holderIndex]
			delete @_register[holderIndex]
			@_saveRegister()
			instance.teardown()

			if @_cache.instances.length == 0
				@_watcher.sleep()

		return
		
	@_loadRegister: ->
		try
			temp = localStorage.getItem @_CFG_.storeKey
			temp = JSON.parse temp
		catch error
			console.log "Oops... Where is your `localStorage`? Or maybe my JSON-string was bad...", error

		temp

	@_saveRegister: ->
		try
			data = JSON.stringify @_register
			localStorage.setItem @_CFG_.storeKey, data
		catch error
			console.log "Oops... Can't save register. `JSON.stringify` or `localStoreage` bark on me.", error

	@_parseRegData: (data) ->
		if data?
			for own idx of data
				isValidIdx = idx < @_holders.length
				isHolderEmpty = not @_isBusy idx
				if isValidIdx and isHolderEmpty
					@_addInstanceAt idx, data[idx], yes
		return

	@_handleMouse: (event) =>
		isHolder = event.target is event.currentTarget
		if isHolder
			target = event.target
			$target = $ target
			isBusy = @_isBusy target

			switch event.type
				when "click"
					if not isBusy
						index = @_getIndex(target)
						@_addInstanceAt index
						console.log "try add TheWidgetInst..."
				when "mouseover"
					$target.addClass @_CFG_.addInstClass
					$target.one "mouseleave", @_handleMouse
				when "mouseleave"
					$target.removeClass @_CFG_.addInstClass

	@_watchCallback: (data) =>
		for inst in @_cache.instances
			if inst? then inst.nextData data

		return

	@_instSuicideCallback: (selfDestroyer) =>
		index = @_cache.instances.indexOf selfDestroyer
		if index > -1
			@_removeInstanceAt index

		return


### Instance ###
theWidgetInstConfig =
	historySize: 25
	baseLine: 155
	easel:
		width: 300
		height: 160
	bar:
		hotBgId: "bg_box_hot_$param"
		tinyHeight: 25
		maxHeight: 150
		width: 10
		spacer: 2
	lbl:
		clsTiny: "tiny"
		indentTinyBottom: 2
		indentLeft: 8

theWidgetInstData = ->
	cfg: theWidgetInstConfig
	barColor: "black"
	hotColor: "black"
	hotBgId: theWidgetInstConfig.bar.hotBgId
	drawData: null
	site: "nameless site"
	limUsers: 0
	minUsers: 0
	maxUsers: 0
	avgUsers: 0

TheWidget = Ractive.extend({
	template: "#template_thewidget"
	data: theWidgetInstData

	_CFG_: theWidgetInstConfig
	_dyingPtr: -1
	_barColor: "black"
	_history: null
	_historySum: 0
	_historySteps: 0
	_min: Number.MAX_VALUE
	_max: 0
	_avg: 0
	_lim: 1

	oninit: () ->
		hotBgId = @get "hotBgId"
		hotBgId = hotBgId.replace "$param", @instId
		@set "hotBgId", hotBgId
		@set "hotColor", "url('#" + hotBgId + "')"
		@set "drawData", []
		@_history = []
		@on { suicide: @suicide }
		return

	setUsersLim: (value) ->
		@_lim = value
		@set "limUsers", value
		return

	setBarColor: (value) ->
		@_barColor = value
		@set "barColor", value
		@_updateDrawData()
		return

	nextData: (currentAmount) ->
		if currentAmount > 0
			overflow = @_history.length >= @_CFG_.historySize
			if overflow then @_history.shift()

			@_history.push currentAmount
			@_historySum += currentAmount
			@_historySteps++
			@_avg = Math.round (@_historySum / @_historySteps)
			@_min = Math.min @_min, currentAmount
			@_max = Math.max @_max, currentAmount

			@_updateDrawData()
			@set "minUsers", @_min
			@set "maxUsers", @_max
			@set "avgUsers", @_avg

		return

	suicide: () ->
		if @suicideCallback?
			@suicideCallback(@)

		return

	_getInfoByIndex: (index) ->
		CFG = @_CFG_
		BAR = CFG.bar
		LBL = CFG.lbl

		amount = @_history[index] || 0
		isAlive = index < @_history.length
		isHot = (if amount then amount >= @_lim else no)
		barSize = if isHot then 1 else amount / @_lim
		height = barSize * BAR.maxHeight
		posX = 0.5 * BAR.spacer + index * (BAR.width + BAR.spacer)
		posY = CFG.baseLine - height
		isTiny = height < BAR.tinyHeight

		result =
			bar:
				bg: if isHot then @get "hotColor" else @_barColor
				x: posX
				y: posY
				w: BAR.width
				h: height
			lbl:
				text: if isAlive then amount else ""
				cls: if isTiny then LBL.clsTiny else ""
				x: posX + LBL.indentLeft
				y: if isTiny then posY - LBL.indentTinyBottom else posY + 0.5 * height

		result

	_updateDrawData: ->
		for index in [0...@_CFG_.historySize]
			data = @_getInfoByIndex index
			@set("drawData[" + index + "]", data)

		return

})


### Watch-helper ###
class ActivityWatcher
	_url = ""
	_delay = 0
	_callback = null
	_askPtr = -1

	constructor: (@url, @_delay, @_callback) ->
		@awake()
		return

	awake: ->
		if @_askPtr is -1
			@_askPtr = 0
			@_ask()

		return

	sleep: ->
		clearTimeout @_askPtr
		@_askPtr = -1
		return

	_ask: () =>
		jQWERTY.post(@_url, @_receive)
		return

	_receive: (data) =>
		@_callback(data)
		@_askPtr = setTimeout @_ask, @_delay
		return


### EXPORT ###
window.TheWidgetManager = TheWidgetMnager