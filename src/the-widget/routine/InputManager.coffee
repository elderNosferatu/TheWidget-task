pkg = window.thewidget = window.thewidget or {}
pkg = pkg.routine = pkg.routine or {}


###*
 * Клас відповідає за роботу з порожніми плейсходерами для віждетів на сторінці
 ###
class InputManager
	_cfg: null
	_holders: null
	_states: null

	constructor: (holderTitle, holderClass, addInstClass, clickCallback) ->
		@_cfg =
			holderClass: holderClass
			holderTitle: holderTitle
			addInstClass: addInstClass
			clickCallback: clickCallback
		@_holders = []
		@_states = []

		@_run()


	setHolderState: (holderOrIndex, isBusy) ->
		if "number" is typeof holderOrIndex
			index = holderOrIndex
			holder = @_holders[index]
		else
			holder = holderOrIndex
			index = @_holders.indexOf holder

		@_states[index] = isBusy
		if isBusy
			$(holder).removeAttr "title"
		else
			$(holder).attr "title", @_cfg.holderTitle


	getHolder: (holderIndex) ->
		@_holders[holderIndex]


	_run: ->
		temp = $("." + @_cfg.holderClass)
		temp.on "mouseover click", @_handleMouse
		for holder in temp
			@_holders.push holder
			@setHolderState holder, no

		return


	_handleMouse: (event) =>
		isHolder = event.target is event.currentTarget
		if isHolder
			target = event.target
			$target = $ target
			index = @_holders.indexOf target
			isBusy = @_states[index]

			unless isBusy
				switch event.type
					when "click"
						@setHolderState index, yes
						$target.removeClass @_cfg.addInstClass
						callback = @_cfg.clickCallback
						if callback?
							callback.call null, target, index
					when "mouseover"
						$target.addClass @_cfg.addInstClass
						$target.one "mouseleave", @_handleMouse
					when "mouseleave"
						$target.removeClass @_cfg.addInstClass



pkg.InputManager = InputManager