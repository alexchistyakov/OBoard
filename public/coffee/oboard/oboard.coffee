window.OBoard =
	currentTutorial: null
	currentBoxId: null

	oboardRequest: null
	tutorials: []
	initialized: false
	init: (data,request,element,url) ->
		@oboardRequest = request
		@element = element
		@oboardUrl = url
		@tutorials = data.tutorials
		@ui.initalize @tutorials
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
		menu: "#oboard-menu"
		initalize: (tutorialNames)->
			$(@menuButton).click ->
				window.OBoard.ui.hideMenuButton()
				window.OBoard.ui.showMenu()
			$("#oboard-menu-close").click ->
				window.OBoard.ui.showMenuButton()
				window.OBoard.ui.hideMenu()
			@addTutorialName tutorial.name for tutorial in tutorialNames
		hideMenuButton: ->
			$(@menuButton).addClass "oboard-menubutton-hidden"
		showMenuButton: ->
			$(@menuButton).removeClass "oboard-menubutton-hidden"
		showMenu: ->
			$(@menu).removeClass "oboard-menu-hidden"
		hideMenu: ->
			$(@menu).addClass "oboard-menu-hidden"
		addTutorialName: (name)->
			element = $("<div class=\"oboard-menu-item\">#{name}</div>")
			element.insertBefore "#oboard-menu-close"
			element.click ->
				console.log "click"
