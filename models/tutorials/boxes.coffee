module.exports = (db,models) ->
	db.define "boxes", 
		order_id : 
			type: "integer"
		text : String
		x:
			type: "integer"
		y:
			type: "integer"
		type: String
		arrow_side: 
			type: "integer"
		bound_path: String
	,
		timestamp: true