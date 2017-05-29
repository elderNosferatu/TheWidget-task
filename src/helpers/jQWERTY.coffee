###*
 * Stub
###
class jQWERTY
	@_STUBS_ = {}

	@post: (url, success) ->
		stub = @_STUBS_[url] = @_STUBS_[url] or new ServerEmulator(url)

		setTimeout(
			-> success(stub.usersAmount)
			stub._responseTime
		)


window.jQWERTY = jQWERTY