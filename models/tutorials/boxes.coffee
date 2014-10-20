module.exports = (db,models) ->
	db.define "boxes", 
		order_id : 
			type: "integer"
		text : String
		bound_id: String
		x:
			type: "integer"
		y:
			type: "integer"
		type: String
		arrow_side: 
			type: "integer"
		bound_path: String
		extras: Object
	,
		timestamp: true