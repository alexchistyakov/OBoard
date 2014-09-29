config = require "../../config"
module.exports = require("stripe") (->
	if config.production
		config.stripe.production
	else
		config.stripe.development
)()