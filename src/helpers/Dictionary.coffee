###*
 * Dictionary - примітивна реалізація одноіменного класу в ActionScript 3.0
 * По суті це така ж хеш-колекція, як нативний Object, але значення її ключів не приводяться до строкового типу
 ###
class Dictionary
	_keys: null
	_values: null


	constructor: ->
		@_keys = []
		@_values = []


	set: (key, value) ->
		idx = @_keys.indexOf key
		if idx is -1 then idx = @_keys.length

		@_keys[idx] = key
		@_values[idx] = value


	get: (key) ->
		idx = @_keys.indexOf key
		if idx isnt -1 then @_values[idx] else undefined


	has: (key) ->
		-1 isnt @_keys.indexOf key


	key: (value) ->
		idx = @_values[value]
		if idx isnt -1 then @_keys[idx] else undefined


	del: (key) ->
		idx = @_keys.indexOf key
		if idx isnt -1
			@_keys.splice idx, 1
			@_values.splice idx, 1


	keys: (safe = true) ->
		if safe then @_keys.slice() else @_keys


	values: (safe = true) ->
		if safe then @_values.slice() else @_values


window.Dictionary = Dictionary