window.OBoard =
	currentTutorial: null
	currentBoxId: null

	oboardRequest: null
	tutorials: {}
	initialized: false
	init: (data,request,element,url) ->
		console.log data
		@oboardRequest = request
		@element = element
		@oboardUrl = url
		for tutorial in data.tutorials
			@tutorials[tutorial.name] = tutorial.tutorial_id
		@ui.initalize @tutorials, data.boxesHtml, data.extrasHtml
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
	unloadAndEndTutorial: ->
		@throwErrUnlessInit()
		@currentTutorial = null
		@currentBoxId = null

	startTutorial: ->
		@throwErrUnlessInit()
		currentBoxId = 0;
		@ui.renderBox(@currentTutorial.boxes[currentBoxId])

	nextBox: ->
		@throwErrUnlessInit()
		unless inTutorial()
			throw new Error "No tutorial loaded"
		currentBoxId++
		@clearBoxes()
		@renderBox currentTutorial.boxes[currentBoxId]
	inTutorial: ->
		@currentTutorial?

	throwErrUnlessInit: ->
		unless @initialized
			throw new Error "OBoard not initialized"

	ui:
		menuButton: "#oboard-menubutton"
		menu: "#oboard-menu"
		closeTutorialButton: "#oboard-close-tutorial-button"
		boxesHtml: {}
		menuVisible: true
		initalize: (tutorials,boxesHtml,extrasHtml)->
			$(@menuButton).click ->
				window.OBoard.ui.showMenu()
				window.OBoard.ui.hideMenuButton()
			$("#oboard-menu-close").click ->
				window.OBoard.ui.showMenuButton()
				window.OBoard.ui.hideMenu()
			$(@closeTutorialButton).click =>
				@renderPopup "Are you sure?", "Would you like to exit the tutorial?", true, (status) ->
					if status
						OBoard.ui.clearBoxes()
						OBoard.unloadAndEndTutorial()
						OBoard.ui.hideCloseTutorialButton()
						OBoard.ui.showMenuButton()
			$(@menu).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
				console.log "Menu "+ @menuVisible
				unless @menuVisible
					$(@menu).hide()
			$(@menuButton).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
				if @menuVisible
					$(@menuButton).hide()
			$(@closeTutorialButton).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
				unless OBoard.inTutorial()
					$(@closeTutorialButton).hide()
			@boxRenderer.boxesHtml = boxesHtml
			@boxRenderer.extrasHtml = extrasHtml
			@addTutorial key for key,value of tutorials

			@hideCloseTutorialButton()
		hideMenuButton: ->
			$(@menuButton).addClass "oboard-menubutton-hidden"
		showMenuButton: ->
			$(@menuButton).show 
				complete: =>
					$(@menuButton).removeClass "oboard-menubutton-hidden"
		showMenu: ->
			$(@menu).show
				complete: =>
					@menuVisible = true
					$(@menu).removeClass "oboard-menu-hidden"
		hideMenu: ->
			$(@menu).addClass "oboard-menu-hidden"
			@menuVisible = false
		addTutorial: (tutorial)->
			element = $("<div class=\"oboard-menu-item\">#{tutorial}</div>")
			element.insertBefore "#oboard-menu-close"
			element.click =>
				@hideMenu()
				OBoard.loadTutorial OBoard.tutorials[tutorial], location.pathname, =>
					OBoard.startTutorial()
					@showCloseTutorialButton()
					@hideMenuButton()
		renderBox: (box) ->
			@boxRenderer.boxes[box.type].render $("body"),@boxRenderer.boxes[box.type].element()

		clearBoxes: ->
			@boxRenderer.removeStandard()
		showCloseTutorialButton: ->
			$(@closeTutorialButton).show
				complete: =>
					$(@closeTutorialButton).removeClass "oboard-menubutton-hidden"
		hideCloseTutorialButton: ->
			$(@closeTutorialButton).addClass "oboard-menubutton-hidden"

		renderPopup: (header,text,cancel,callback) ->
			@removePopup()
			$popup = @boxRenderer.boxes.boxpopup.element "Do you want to exit the tutorial?"
			@boxRenderer.extras.header.add $popup,
				text: "Are you sure?"
			@boxRenderer.extras.promptbuttons.add $popup,
				callback: (status) =>
					if status
						OBoard.unloadAndEndTutorial()
						@hideCloseTutorialButton()
						@showMenuButton()
					@removePopup()

			@boxRenderer.boxes.boxpopup.render $("body"), $popup

		removePopup: ->
			@boxRenderer.boxes.boxpopup.remove()
		boxRenderer:
			boxHtml: {}
			extrasHtml: {}
			removeStandard: ->
				$(".oboard-box").remove()
			boxes:
				boxsimple:
					render: ($parent,element) ->
						$parent.append element
					element: (text,data) ->
						jbox = $(OBoard.ui.boxRenderer.boxesHtml["boxsimple"])
						jbox.text text
						jbox.css "top", "#{data.y}"
						jbox.css "right","#{data.x}"
						jbox
					remove: ->
						OBoard.ui.boxRenderer.removeStandard()


				boxpopup:
					overlay: null
					render: ($parent,element) ->
						$parent.append $(@overlay)
						$parent.append element
					element: (text,data) ->
						$popup = $(OBoard.ui.boxRenderer.boxesHtml["boxpopup"])
						$popup.find(".oboard-popup-body").text text
						@overlay = $popup.get 0
						$($popup.get(2))
					remove: ->
						$(".oboard-popup").remove()
						$(@overlay).remove()

			extras:
				header:
					add: (box,data)->
						$header = $(OBoard.ui.boxRenderer.extrasHtml["header"])
						$header.append data.text
						box.prepend $header
				okbutton:
					add: (box,data) ->
						$button = $(extrasHtml["okbutton"])
						box.append $button
						$button.find("#oboard-next-button").click =>
							data.callback()
				promptbuttons:
					add: (box,data) ->
						$buttons = $(OBoard.ui.boxRenderer.extrasHtml["promptbuttons"])
						box.append $buttons
						$buttons.find("#oboard-next-button").click =>
							data.callback true
						$buttons.find("#oboard-cancel-button").click =>
							data.callback false



