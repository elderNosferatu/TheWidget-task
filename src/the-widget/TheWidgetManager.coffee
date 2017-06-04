pkg = window.thewidget = window.thewidget or {}


# something like import
InputManager = pkg.routine.InputManager
RegisterManager = pkg.routine.RegisterManager
TheWidget = pkg.TheWidget


class TheWidgetManager
	_cfg: null
	_cache: null
	_mgrRegister: null
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

		if options?
			for key, value of options
				@_cfg[key] = value


	run: ->
		cfg = @_cfg
		@_mgrInput = new InputManager(cfg.holderTitle, cfg.holderClass, cfg.addInstClass, @_clbInput)
		@_mgrRegister = new RegisterManager(cfg.storeKey)
		@_mgrRegister.load()
		@_mgrRegister.forEach @_addFromReg


	_addInstance: (holderInstance, holderIndex, instanceData = null) ->
		cfg = @_cfg
		opts = instanceData or {}
		opts.site = opts.site or cfg.defaultSite
		opts.limUsers = opts.limUsers or cfg.limUsers
		unless opts.color?
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
		@_mgrInput.setHolderState holderIndex, true
		@_mgrRegister.set holderIndex, opts


	_removeInstance: (instance, holderInstance, holderIndex) ->
		delete @_cache[holderIndex]
		instance.teardown()
		@_mgrInput.setHolderState holderIndex, off
		@_mgrRegister.set holderIndex, null


	_addFromReg: (holderIndex, instanceData) =>
		holder = @_mgrInput.getHolder holderIndex
		@_addInstance holder, holderIndex, instanceData


	_clbInput: (holderInstance, holderIndex) =>
		@_addInstance holderInstance, holderIndex
		@_mgrRegister.save()


	_clbInstSuicide: (instance) =>
		holderIndex = instance.position
		holderInstance = @_mgrInput.getHolder holderIndex
		@_removeInstance instance, holderInstance, holderIndex
		@_mgrRegister.save()




pkg.TheWidgetManager = TheWidgetManager