$(document).ready ->
	menuButton = $("#oboard-menubutton")
	console.log menuButton
	menuButton.click ->
		console.log "CLICK"
		menuButton.addClass "oboard-menubutton-hidden"