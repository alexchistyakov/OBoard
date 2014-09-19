crypto = require "crypto"
stripe = require "../lib/stripe"
rand = require "generate-key"
module.exports = (db,models) ->
	users = db.define "users",
		pub_id:
			type: "text"
		username: 
			type: "text"
			required: true
		email:
			type: "text"
			required: true
		password:
			type: "text"
			required: true
		stripe: String
	,
		timestamp: true
		hooks:
			beforeCreate: ->
				@pub_id = rand.generateKey Math.floor(Math.random() * 15) + 15
				@password = @hash @password
			afterCreate: (success) ->
				if success
					@addStripe()
			beforeSave: ->
				@username = @username.capitalize()
		methods:
			hash: (data) ->
				crypto.createHash("md5").update(data).digest("hex")
			addStripe: =>
				# ---- Coming soon ---- #
				###stripe.customers.create 
					email: @email
				, (error,customer)=>
					if not err and customer
						@stripe = customer.id
						@save()###
		validations:
			pub_id: db.enforce.unique()
			email: [
				db.enforce.patterns.email()
				db.enforce.unique()
			]
			username: db.enforce.unique()

	users.hash = (data) ->
		crypto.createHash("md5").update(data).digest("hex")
		
	users
