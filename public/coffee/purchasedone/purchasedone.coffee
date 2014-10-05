$ ->
	$(".purchase-loading-text").text "Your purchase is complete. You will be redirected in 5 seconds."
	setTimeout ->
		window.location.href = "/"
	, 5000