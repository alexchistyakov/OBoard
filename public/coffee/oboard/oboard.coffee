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
			boxClass = @boxRenderer.createBox box.type,box.bound_id,box.text,box.data
			header = @boxRenderer.createExtra "header", boxClass,
				text: "Testing shit"
			boxClass.extra header
			boxClass.render()
		showCloseTutorialButton: ->
			$(@closeTutorialButton).show
				complete: =>
					$(@closeTutorialButton).removeClass "oboard-menubutton-hidden"
		hideCloseTutorialButton: ->
			$(@closeTutorialButton).addClass "oboard-menubutton-hidden"

		renderPopup: (header,text,cancel,callback) ->
			popup = @boxRenderer.createBox "boxpopup",null,"Do you want to exit the tutorial?", null
			header = @boxRenderer.createExtra "header",popup,
				text: "Are you sure?"
			promptbuttons = @boxRenderer.createExtra "promptbuttons",popup,
				callback: (status) =>
					if status
						OBoard.unloadAndEndTutorial()
						@hideCloseTutorialButton()
						@showMenuButton()
						@boxRenderer.clearBoxes()
					@boxRenderer.removeBox popup
			popup.extra promptbuttons
			popup.extra header
			popup.render()
			

		removePopup: ->
			@boxRenderer.clearBoxes()
		boxRenderer:
			boxHtml: {}
			extrasHtml: {}
			activeBoxes: []
			createBox: (type,parent,text,data) ->
				new @boxes[type] parent,text,data
			createExtra: (type,box,data) ->
				new @extras[type] box,data
			clearBoxes: ->
				for box in @activeBoxes
					box.unrender()
				activeBoxes = []
			removeBox: (box) ->
				box.unrender()
				@activeBoxes.pop box
			boxes:
				boxsuperclass: class Box
					constructor: (parent,text,data,type)->
						@text = text
						@data = data
						console.log data
						@parent = parent
						@html = OBoard.ui.boxRenderer.boxesHtml[type]
						@extras = []
					render: ->
						OBoard.ui.boxRenderer.activeBoxes.push @
						$element = @element()
						@appendExtras $element
						@appendToParent $element
					appendToParent: ($element)->
						if @parent?
							@parent.append $element
						else
							$("body").append $element
					appendExtras: ($element) ->
						for extra in @extras
							extra.append $element
					element: ->
						$("")
					unrender: ->

					extra: (extra)->
						@extras.push extra
				boxsimple: class BoxSimple extends Box
					constructor: (parent,text,data) ->
						super parent,text,data, "boxsimple"
					element: ->
						jbox = $(@html)
						jbox.text @text
						jbox.css "top", "#{@data.y}"
						jbox.css "right","#{@data.x}"
						jbox
					unrender: ->
						$(".oboard-box").remove()


				boxpopup: class BoxPopup extends Box
					constructor: (parent,text,data) ->
						super parent,text,data, "boxpopup"
					appendExtras: ($element) ->
						for extra in @extras
							extra.append $($element.get 2)
					element: ->
						$popup = $(@html)
						$popup.find(".oboard-popup-body").text @text
						$popup
					unrender: ->
						$(".oboard-popup").remove()
						$(".oboard-darken-overlay").remove()

			extras:
				extrasuperclass: class Extra
					constructor: (box,data,type) ->
						@box = box
						@data = data
						@html = OBoard.ui.boxRenderer.extrasHtml[type]
					append: ($element)->
						$("")
				header: class Header extends Extra
					constructor: (box,data) ->
						super box,data, "header"
					append: ($element)->
						$header = $(@html)
						$header.append @data.text
						$element.prepend $header
				okbutton: class OkButton extends Extra
					constructor: (box,data) ->
						super box,data, "okbutton"
					append: ($element) ->
						$button = $(@html)
						$element.append $button
						$button.find("#oboard-next-button").click =>
							@data.callback()
				promptbuttons: class PromptButtons extends Extra
					constructor: (box,data) ->
						super box,data, "promptbuttons"
					append: ($element) ->
						$buttons = $(@html)
						$element.append $buttons
						$buttons.find("#oboard-next-button").click =>
							@data.callback true
						$buttons.find("#oboard-cancel-button").click =>
							@data.callback false



