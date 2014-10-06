rand = require "generate-key"
module.exports = (db,models) ->
	db.define "projects",
		pub_id: 
			type: "text"
		name:
			type: "text"
		host:
			type: "text"
	,
		timestamp: true
		hooks:
			beforeCreate: ->
				@pub_id = rand.generateKey Math.floor(Math.random() * 15) + 15
		validations:
			pub_id: db.enforce.unique()