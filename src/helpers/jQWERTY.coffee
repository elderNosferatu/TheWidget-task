###*
 * Заглушка, що містить пародію на $.post(...)
 * На відміну від попередньої версії, дана функція реагує на параметр `url`,
 * створюючи для унікальних адрес окремий эмулятор сервера
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