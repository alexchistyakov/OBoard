$ ->
	$("body").append $("<script
    src=\"https://checkout.stripe.com/checkout.js>\"
  </script>")
	interval = setInterval ->
		if StripeCheckout?
			timeout = setTimeout ->
				$(".purchase-loading-text").text "If the the purchase form has not opened by now, please check you internet connection and refresh the page"
			, 10000
			clearInterval interval
			tokenReceived = false
			handler = StripeCheckout.configure
				key: 'pk_test_z0UfeI4dB8HO4Tgd2lQElJih'
				token: (token)=>
					tokenReceived = true
					$("<form method=\"post\" action=\"#{oboardRootUrl}/purchase\"><input type=\"text\" value=\"#{token.id}\"></form>").submit()
			handler.open 
				name: "OBoard"
				description: "OBoard Service ($20.00)"
				amount: 2000
				opened: ->
					clearTimeout timeout
				closed: ->
					unless tokenReceived
						$(".purchase-loading-text").text "You have closed the form. Please refresh the page to retry"

	, 10