stripe = require "../../lib/stripe"
config = require "../../config"
module.exports.loadPurchasePage = (req,res,next) ->
	unless req.user?
		res.render "purchase/notloggedin"
	else
		res.render "purchase/index",
			title: "Purchase"
			text: "One moment please..."
			js: req.coffee.renderTags "purchase"
			css: req.css.renderTags "purchase"
module.exports.doPurchase = (req,res,next) ->
	unless req.user?
		res.render "purchase/notloggedin"
	token = req.param "token"
	stripe.charges.create 
		amount: config.price
		currency: config.currency
		card: token
	, (err,charge) ->
		if err? and err.type is "StripeCardError"
			res.render "purchase/index",
				title: "Purchase Status"
				css: req.css.renderTags "purchase"
				js: ""
				text: "Your purchase could not be completed. Error: #{err.message}"
		else
			
			res.render "purchase/index",
				title: "Purchase Status"
				css: req.css.renderTags "purchase"
				js: req.coffee.renderTags "purchasedone"
				text: "Your purchase has been completed. You will be redirected shortly."
