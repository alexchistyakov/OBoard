module.exports = (db,models) ->
	db.define "boxes", 
		order_id : 
			type: "integer"
		text : String
		bound_id : String
		type: String
		arrow_side: 
			type: "integer"
		bound_path: String
	,
		timestamp: true