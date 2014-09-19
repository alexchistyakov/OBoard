rand = require "generate-key"
module.exports = (db,models) ->
	db.define "tutorials",{
		pub_id: 
			type: "text"
		name : 
			type: "text"
			required: true
		host : 
			type: "text"
			required: true
	},{
		timestamp: true
		hooks:
			beforeCreate: ->
				@pub_id = rand.generateKey Math.floor(Math.random() * 15) + 15
		validations:
			pub_id: db.enforce.unique()
	}