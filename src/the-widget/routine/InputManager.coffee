pkg = window.thewidget = window.thewidget or {}
pkg = pkg.routine = pkg.routine or {}


class InputManager
	_cfg:
		holderClass: null
		addInstClass: null
		clickCallback: null
	_holders: null
	_states: null

	constructor: (holderClass, addInstClass, clickCallback) ->
		@_cfg =
			holderClass: holderClass
			addInstClass: addInstClass
			clickCallback: clickCallback
		@_holders = []
		@_states = []

		@_run()


	setHolderState: (holderIndex, isBusy) ->
		@_states[holderIndex] = isBusy


	getHolderIndex: (holderInstance) ->
		@_holders.indexOf holderInstance


	getHolder: (holderIndex) ->
		@_holders[holderIndex]


	_run: ->
		temp = $("." + @_cfg.holderClass)
		for holder in temp
			@_holders.push holder
			$(holder).on "mouseover click", @_handleMouse

		@_states.length = @_holders.length


	_handleMouse: (event) =>
		isHolder = event.target is event.currentTarget
		if isHolder
			target = event.target
			$target = $ target
			index = @_holders.indexOf target
			isBusy = @_states[index]

			switch event.type
				when "click"
					unless isBusy
						callback = @_cfg.clickCallback
						if callback?
							callback.call null, target, index
				when "mouseover"
					$target.addClass @_cfg.addInstClass
					$target.one "mouseleave", @_handleMouse
				when "mouseleave"
					$target.removeClass @_cfg.addInstClass



pkg.InputManager = InputManager