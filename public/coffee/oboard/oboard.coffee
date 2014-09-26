window.OBoard =
	currentTutorial: null
	currentBoxId: null

	oboardRequest: null
	tutorials: {}
	initialized: false
	init: (data,request,element,url) ->
		@oboardRequest = request
		@element = element
		@oboardUrl = url
		for tutorial in data.tutorials
			@tutorials[tutorial.name] = tutorial.tutorial_id
		@ui.initalize @tutorials, data.boxesHtml
		@initialized = true

	loadTutorial: (pub_id,path,callback) ->
		@throwErrUnlessInit()
		params =
			command: "load-tutorial"
			tutorial_id: pub_id
			path: path
		@oboardRequest params, "GET", (response) ->
			console.log response
			unless response is false
				@currentTutorial = response.data
				@currentBoxId = -1
				callback() if callback?
	# TODO
	unloadTutorial: ->
		@throwErrUnlessInit()
		currentTutorial = null
		currentBoxId = null

	startTutorial: ->
		@throwErrUnlessInit()
		currentBoxId = 0;
	throwErrUnlessInit: ->
		unless @initialized
			throw new Error "OBoard not initialized"

	ui:
		menuButton: "#oboard-menubutton"
		menu: "#oboard-menu"
		boxesHtml: {}
		initalize: (tutorials,boxesHtml)->
			$(@menuButton).click ->
				window.OBoard.ui.hideMenuButton()
				window.OBoard.ui.showMenu()
			$("#oboard-menu-close").click ->
				window.OBoard.ui.showMenuButton()
				window.OBoard.ui.hideMenu()
			@boxesHtml = boxesHtml
			@addTutorial key for key,value of tutorials
		hideMenuButton: ->
			$(@menuButton).addClass "oboard-menubutton-hidden"
		showMenuButton: ->
			$(@menuButton).removeClass "oboard-menubutton-hidden"
		showMenu: ->
			$(@menu).removeClass "oboard-menu-hidden"
		hideMenu: ->
			$(@menu).addClass "oboard-menu-hidden"
		addTutorial: (tutorial)->
			element = $("<div class=\"oboard-menu-item\">#{name}</div>")
			element.insertBefore "#oboard-menu-close"
			element.click ->
				window.OBoard.ui.hideMenu()
				window.OBoard.ui.showMenuButton()
				window.OBoard.loadTutorial window.OBoard.tutorials[name], location.pathname, ->
					window.OBoard.startTutorial()
		renderBox: (box) ->
			jbox = $(boxesHtml[box.type])
			jbox.text box.text
			$("#"+box.bound_id).append jbox

