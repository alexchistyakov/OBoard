module.exports = (db,models) ->
	db.define "boxes", 
		order_id : 
			type: "integer"
		text : String
		bound_id : String
		popup: Boolean
		next_button: Boolean
		arrow_side: 
			type: "integer"
	,
		timestamp: true