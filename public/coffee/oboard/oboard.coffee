window.OBoard =
	currentTutorial: null
	currentBoxId: null

	oboardRequest: null

	initialized: false
	init: (request,element,url) ->
		@oboardRequest = request
		@element = element
		@oboardUrl = url
		@ui.initalize()
		@initialized = true

	loadTutorial: (pub_id,frombox,tobox,callback) ->
		throwErrUnlessInit()
		params =
			command: "load-tutorial"
			tutorial_id: pub_id
			frombox: frombox
			tobox: tobox
		@oboardRequest params, "GET", (response) ->
			unless response is false
				@currentTutorial = response.data
				@currentBoxId = -1
				callback()
	# TODO
	unloadTutorial: ->
		throwErrUnlessInit()
		currentTutorial = null
		currentBoxId = null

	startTutorial: ->
		throwErrUnlessInit()
		currentBoxId = 0;
	throwErrUnlessInit: ->
		unless initialized
			throw new Error "OBoard not initialized"

	ui:
		menuButton: "#oboard-menubutton"
		initalize: ->
			$(@menuButton).click ->
				console.log "CLICK"
				window.OBoard.ui.hideMenuButton()
		hideMenuButton: ->
			$(@menuButton).addClass "oboard-menubutton-hidden"
		showMenuButton: ->
			$(@menuButton).removeClass "oboard-menubutton-hidden"
