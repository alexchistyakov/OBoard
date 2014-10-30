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
		@ui.initialize @tutorials, data.boxesHtml, data.extrasHtml, data.menuItemHtml
		cookie = @getTutorialCookie()
		if cookie.tutorialId? and cookie.boxIndex?
			@downloadTutorialData cookie.tutorialId, (tutorial)->
				if tutorial.boxes[0]? and tutorial.boxes[0].order_id is cookie.boxIndex + 1
					@loadTutorial tutorial
					@startTutorial() 
				else
					@ui.menu.showMenuButton()
		else
			@ui.menu.showMenuButton()
		@initialized = true

	downloadTutorialData: (pub_id,callback) ->
		params =
			command: "load-tutorial"
			tutorial_id: pub_id
			path: location.pathname
		
		@oboardRequest params, "GET", (response) =>
			unless response is false
				unless response.success
					throw new Error response.data.message
				callback response if callback?

	loadTutorial: (tutorial) ->
		@throwErrUnlessInit()
		@currentTutorial = tutorial
		for i in [0..@currentTutorial.boxes.length]
			for j in [0..@currentTutorial.boxes.length]
				if @currentTutorial.boxes[i].order_id < @currentTutorial.boxes[j]
					temp = @currentTutorial.boxes[i]
					@currentTutorial.boxes[i] = @currentTutorial.boxes[j]
					@currentTutorial.boxes[j] = temp
		@currentBoxId = -1
	unloadAndEndTutorial: ->
		@throwErrUnlessInit()
		@ui.boxRenderer.clearBoxes()
		@currentTutorial = null
		@currentBoxId = null

	startTutorial: ->
		@throwErrUnlessInit()
		unless @inTutorial()
			throw new Error "Not in tutorial"
		@currentBoxId = 0;
		@ui.menu.hideMenu()
		@ui.menu.showCloseTutorialButton()
		@ui.menu.hideMenuButton()
		@ui.renderBox(@currentTutorial.boxes[@currentBoxId]) if @currentTutorial.boxes[@currentBoxId]?

	nextBox: ->
		@throwErrUnlessInit()
		unless @inTutorial()
			throw new Error "No tutorial loaded"
		@currentBoxId++
		@ui.boxRenderer.clearBoxes()
		if @currentTutorial.boxes[@currentBoxId]?
			@ui.renderBox @currentTutorial.boxes[@currentBoxId]
		else
			@unloadAndEndTutorial()
			@ui.menu.hideCloseTutorialButton()
			@ui.menu.showMenuButton()
	inTutorial: ->
		@currentTutorial?

	throwErrUnlessInit: ->
		unless @initialized
			throw new Error "OBoard not initialized"

	getTutorialCookie: ->
		tutorialId = @getCookie "oboardTutorial"
		boxIndex = @getCookie "oboardTutorialLastBox"
		{
			tutorialId: if not not tutorialId then tutorialId else null
			boxIndex: if not not boxIndex then boxIndex else null
		} 

	setCookie: (cname, cvalue, exhours) ->
		date = new Date()
		date.setTime date.getTime() + (exhours*60*60*1000)
		expires = "expires="+d.toUTCString()
		document.cookie = cname + "=" + cvalue + "; " + expires
	
	getCookie: (cname) ->
		name = "#{cname}="
		ca = document.cookie.split ";"
		for cookie in ca
			while cookie.charAt(0) is ' '
				return cookie = cookie.substring 1 
			return cookie.substring(name.length,cookie.length) unless cookie.indexOf(name) is -1
		return ""
	createTutorialCookie: ->
		unless @inTutorial
			throw new Error "Not in tutorial"
		@setCookie "oboardTutorial",@currentTutorial.tutorial_id, 0.1
		@setCookie "oboardTutorialLastBox", @currentTutorial.boxes[@currentBoxId].order_id, 0.1
	removeTutorialCookie: ->
		@setCookie "oboardTutorial","",-1
		@setCookie "oboardTutorialLastBox","",-1
	ui:
		initialize: (tutorials,boxesHtml,extrasHtml,menuItemHtml)->
			@menu.initialize tutorials,menuItemHtml
			@boxRenderer.initialize boxesHtml,extrasHtml
		renderBox: (box) ->
			boxClass = @boxRenderer.createBox box.type,box.bound_id,box.text,box.data
			for name,data of box.extras
				extra = @boxRenderer.createExtra name,data
				boxClass.extra extra
			boxClass.render()
		calculateScrollToCenter: (element) ->
			elOffset = element.offset().top
			elHeight = element.height()
			windowHeight = $(window).height()
			offset

			if elHeight < windowHeight
				offset = elOffset - ((windowHeight / 2) - (elHeight / 2));
			else
				offset = elOffset;
			offset

		renderPopup: (header,text,cancel,callback) ->
			popup = @boxRenderer.createBox "boxpopup",null,text, null
			header = @boxRenderer.createExtra "header",
				text: header
			if cancel
				promptbuttons = @boxRenderer.createExtra "promptbuttons",
					callback: callback
				popup.extra promptbuttons
			popup.extra header
			popup.render()
			

		removePopup: ->
			@boxRenderer.clearBoxes()
		menu:
			menuButton: "#oboard-menubutton"
			menuWindow: "#oboard-menu"
			closeTutorialButton: "#oboard-close-tutorial-button"
			menuVisible: true
			initialize: (tutorials,menuItemHtml) ->
				@menuItemHtml = menuItemHtml
				$(@menuButton).click =>
					@showMenu()
					@hideMenuButton()
				$("#oboard-menu-close").click =>
					@showMenuButton()
					@hideMenu()
				$(@closeTutorialButton).click =>
					OBoard.ui.renderPopup "Are you sure?", "Would you like to exit the tutorial?", true, (status) =>
						if status
							OBoard.unloadAndEndTutorial()
							@hideCloseTutorialButton()
							@showMenuButton()
						OBoard.ui.boxRenderer.removeBox popup
				$(@menuWindow).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
					unless @menuVisible
						$(@menuWindow).hide()
				$(@menuButton).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
					if @menuVisible
						$(@menuButton).hide()
				$(@closeTutorialButton).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
					unless OBoard.inTutorial()
						$(@closeTutorialButton).hide()
				@addTutorial key for key,value of tutorials

				@hideCloseTutorialButton()
				@hideMenu()
				@hideMenuButton()
			hideMenuButton: ->
				$(@menuButton).addClass "oboard-menubutton-hidden"
			showMenuButton: ->
				$(@menuButton).show 
					complete: =>
						$(@menuButton).removeClass "oboard-menubutton-hidden"
			showMenu: ->
				$(@menuWindow).show
					complete: =>
						@menuVisible = true
						$(@menuWindow).removeClass "oboard-menu-hidden"
			hideMenu: ->
				$(@menuWindow).addClass "oboard-menu-hidden"
				@menuVisible = false
			addTutorial: (tutorial)->
				element = $(@menuItemHtml)
				element.find(".oboard-menu-item-body").text tutorial
				element.insertBefore "#oboard-menu-close"
				element.click =>
					OBoard.downloadTutorialData OBoard.tutorials[tutorial], (tutorial)->
						OBoard.loadTutorial tutorial
						OBoard.startTutorial()
			showCloseTutorialButton: ->
				$(@closeTutorialButton).show
					complete: =>
						$(@closeTutorialButton).removeClass "oboard-menubutton-hidden"
			hideCloseTutorialButton: ->
				$(@closeTutorialButton).addClass "oboard-menubutton-hidden"
		boxRenderer:
			boxHtml: {}
			extrasHtml: {}
			activeBoxes: []
			initialize: (boxHtml,extrasHtml) ->
				@boxHtml = boxHtml
				@extrasHtml = extrasHtml
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
				boxsuperclass: class OBoardBox
					constructor: (parent,text,data,type)->
						@text = text
						@data = data
						console.log data
						@parent = parent
						@html = OBoard.ui.boxRenderer.boxHtml[type]
						@extras = []
					render: ->
						OBoard.ui.boxRenderer.activeBoxes.push @
						$element = @element()
						@appendExtras $element
						@appendToParent $element
					appendToParent: ($element)->
						if @parent?
							$("#"+@parent).append $element
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
				boxsimple: class OBoardBoxSimple extends OBoardBox
					constructor: (parent,text,data) ->
						super parent,text,data, "boxsimple"
					element: ->
						jbox = $(@html)
						jbox.find(".oboard-box-body").text @text
						jbox.offset
							top: @data.y
							left: @data.x
						jbox

					render: ->
						super()
						$('html, body').animate
							scrollTop: OBoard.ui.calculateScrollToCenter $(".oboard-box")
						, 500
					unrender: ->
						$(".oboard-box").remove()


				boxpopup: class OBoardBoxPopup extends OBoardBox
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
				extrasuperclass: class OBoardExtra
					constructor: (data,type) ->
						@data = data
						@html = OBoard.ui.boxRenderer.extrasHtml[type]
					append: ($element)->
						$("")
				header: class OBoardHeader extends OBoardExtra
					constructor: (data) ->
						super data, "header"
					append: ($element)->
						$header = $(@html)
						$header.append @data.text
						$element.prepend $header
				okbutton: class OBoardOkButton extends OBoardExtra
					constructor: (data) ->
						super data, "okbutton"
					append: ($element) ->
						$button = $(@html)
						$element.append $button
						$button.find("#oboard-next-button").click =>
							OBoard.nextBox()
				promptbuttons: class OBoardPromptButtons extends OBoardExtra
					constructor: (data) ->
						super data, "promptbuttons"
					append: ($element) ->
						$buttons = $(@html)
						$element.append $buttons
						$buttons.find("#oboard-next-button").click =>
							@data.callback true
						$buttons.find("#oboard-cancel-button").click =>
							@data.callback false
				clicktrigger: class OBoardClickTrigger extends OBoardExtra
					constructor: (data) ->
						super data, "clicktrigger"
					append: ($element) ->
						$(@data.triggerId).click ->
							if OBoard.inTutorial()
								OBoard.nextBox()



