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
		@oboardRequest params, "GET", (response) =>
			console.log response
			unless response is false
				unless response.success
					throw new Error response.data.message
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
		menuVisible: true
		initalize: (tutorials,boxesHtml)->
			$(@menuButton).click ->
				window.OBoard.ui.showMenu()
				window.OBoard.ui.hideMenuButton()
			$("#oboard-menu-close").click ->
				window.OBoard.ui.showMenuButton()
				window.OBoard.ui.hideMenu()
			$(@menu).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
				console.log "Menu "+ @menuVisible
				unless @menuVisible
					$(@menu).hide()
			$(@menuButton).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
				if @menuVisible
					$(@menuButton).hide()
				console.log "Button "+ @menuVisible
			@boxesHtml = boxesHtml
			@addTutorial key for key,value of tutorials
		hideMenuButton: ->
			$(@menuButton).addClass "oboard-menubutton-hidden"
		showMenuButton: ->
			$(@menuButton).show 
				complete: =>
				$(@menuButton).removeClass "oboard-menubutton-hidden"
		showMenu: ->
			$(@menu).show
				complete: =>
					console.log "Doing"
					@menuVisible = true
					$(@menu).removeClass "oboard-menu-hidden"
		hideMenu: ->
			$(@menu).addClass "oboard-menu-hidden"
			@menuVisible = false
		addTutorial: (tutorial)->
			element = $("<div class=\"oboard-menu-item\">#{name}</div>")
			element.insertBefore "#oboard-menu-close"
			element.click ->
				window.OBoard.ui.hideMenu()
				window.OBoard.ui.showMenuButton()
				window.OBoard.loadTutorial window.OBoard.tutorials[tutorial], location.pathname, ->
					window.OBoard.startTutorial()
		renderBox: (box) ->
			jbox = $(@boxesHtml[box.type])
			console.log @boxesHtml[box.type]
			jbox.text box.text
			$("#"+box.bound_id).append jbox
		clearBoxes: ->
			$(".oboard-box").remove()
