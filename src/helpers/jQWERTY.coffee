$.post = (url, success) ->
	amount = Math.round( 200 * Math.random() )
	setTimeout(
		-> success amount
		1e3
	)