pkg = window.thewidget = window.thewidget or {}


# something like import
InputManager = pkg.routine.InputManager
TheWidget = pkg.TheWidget


class TheWidgetManager
	_cfg: null
	_cache: null
	_register: null
	_mgrInput: null


	constructor: (options = null) ->
		@_cfg =
			colors: ["gray", "navy", "green", "olive", "teal", "blue", "purple", "maroon", "red"]
			holderTitle: "add The-Widget"
			holderClass: "place_holder"
			addInstClass: "place_holder-mouseover"
			serverUrl: "the-widget.script"
			storeKey: "TheWidget:register"
			defaultSite: "."
			limUsers: 150
		@_cache = {}
		@_register = {}

		if options?
			for key, value of options
				@_cfg[key] = value


	run: ->
		cfg = @_cfg
		@_mgrInput = new InputManager(cfg.holderTitle, cfg.holderClass, cfg.addInstClass, @_clbInput)
		@_regLoad()
		@_restorePrevSession()


	_regLoad: ->
		try
			temp = localStorage.getItem @_cfg.storeKey
			temp = JSON.parse temp
		catch error
			null # Just a trick for WebStorm's code folding

		@_register = temp or {}
	
	
	_regSave: ->
		try
			temp = JSON.stringify @_register
			localStorage.setItem @_cfg.storeKey, temp
		catch error
			null # Just a trick for WebStorm's code folding
	
	
	_restorePrevSession: ->
		for key, value of @_register
			idx = parseInt(key) or 0
			holder = @_mgrInput.getHolder idx
			@_addInstance holder, idx, value
			
		return
	
	
	_addInstance: (holderInstance, holderIndex, instanceData = null) ->
		cfg = @_cfg
		opts = instanceData or {}
		opts.site = opts.site or cfg.defaultSite
		opts.limUsers = opts.limUsers or cfg.limUsers
		unless opts.barColor?
			opts.barColor = XMath.arrRnd cfg.colors

		theInst = new TheWidget({
			el: holderInstance
			position: holderIndex
			suicideCallback: @_clbInstSuicide
			initialData:
				instId: Date.now()
				barColor: opts.barColor
				limUsers: opts.limUsers
				site: opts.site
				serverUrl: cfg.serverUrl
		})

		@_cache[holderIndex] = theInst
		@_register[holderIndex] = opts
		@_mgrInput.setHolderState holderIndex, true


	_removeInstance: (instance, holderInstance, holderIndex) ->
		delete @_cache[holderIndex]
		delete @_register[holderIndex]
		instance.teardown()
		@_mgrInput.setHolderState holderIndex, off


	_clbInput: (holderInstance, holderIndex) =>
		@_addInstance holderInstance, holderIndex
		@_regSave()


	_clbInstSuicide: (instance) =>
		holderIndex = instance.position
		holderInstance = @_mgrInput.getHolder holderIndex
		@_removeInstance instance, holderInstance, holderIndex
		@_regSave()




pkg.TheWidgetManager = TheWidgetManager