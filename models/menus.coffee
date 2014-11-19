module.exports = (db,models) ->
	db.define "menus",
		button_color: 
			type: "text"
		button_header:
			type: "text"
		menu_header:
			type: "text"
		details_background:
			type: "text"
	,
		timestamp: true