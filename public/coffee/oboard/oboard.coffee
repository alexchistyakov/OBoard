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
		@ui.initialize @tutorials, data.boxesHtml, data.extrasHtml, data.menuItemHtml, data.menuData
		cookie = @getTutorialCookie()
		if cookie.tutorialId? and cookie.boxIndex?
			console.log cookie
			@downloadTutorialData cookie.tutorialId, (tutorial) =>
				if tutorial.boxes[0]? and tutorial.boxes[0].order_id is parseInt(cookie.boxIndex) + 1
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
				console.log response
				unless response.success
					throw new Error response.data.message
				callback response.data if callback?	
	loadTutorial: (tutorial) ->
		@throwErrUnlessInit()
		@currentTutorial = tutorial
		@currentTutorial.boxes = @util.bubbleSort @currentTutorial.boxes
		@currentBoxId = -1

	unloadAndEndTutorial: ->
		@throwErrUnlessInit()
		@ui.boxRenderer.clearBoxes()
		@currentTutorial = null
		@currentBoxId = null
	closeTutorial: ->
		@throwErrUnlessInit()
	startTutorial: ->
		@throwErrUnlessInit()
		
		@currentBoxId = 0;
		@ui.menu.hideMenu()
		@ui.menu.showCloseTutorialButton()
		@ui.menu.hideMenuButton()
		@ui.renderBox(@currentTutorial.boxes[@currentBoxId]) if @currentTutorial.boxes[@currentBoxId]?

	nextBox: ->
		@throwErrUnlessInit()
		@throwErrUnlessInTutorial()
		@ui.boxRenderer.clearBoxes()
		if @currentTutorial.boxes[@currentBoxId++]? and @currentBoxId < @currentTutorial.boxes.length
			@ui.renderBox @currentTutorial.boxes[@currentBoxId]
		else
			if @currentTutorial.end
				@unloadAndEndTutorial()
				@ui.menu.hideCloseTutorialButton()
				@ui.menu.showMenuButton()
			else
				@createTutorialCookie()
	previousBox: ->
		@throwErrUnlessInit()
		@throwErrUnlessInTutorial()
		@ui.boxRenderer.clearBoxes()
		unless @currentBoxId <= 0
			@ui.renderBox @currentTutorial.boxes[@currentBoxId--]
	goToBox: (index) ->
		@throwErrUnlessInit()
		@throwErrUnlessInTutorial()
		@ui.boxRenderer.clearBoxes()
		if @currentTutorial.boxes[index]?
			@ui.renderBox @currentTutorial.boxes[index]
		else
			throw new Error "No such box"
	inTutorial: ->
		@currentTutorial?

	throwErrUnlessInit: ->
		unless @initialized
			throw new Error "OBoard not initialized"
	throwErrUnlessInTutorial: ->
		unless @inTutorial()
			throw new Error "Not in tutorial"
	getTutorialCookie: ->
		tutorialId = @util.getCookie "oboardTutorial"
		boxIndex = @util.getCookie "oboardTutorialLastBox"
		console.log tutorialId
		{
			tutorialId: tutorialId or null
			boxIndex: boxIndex or null
		} 

	createTutorialCookie: ->
		unless @inTutorial
			throw new Error "Not in tutorial"
		@util.setCookie "oboardTutorial",@currentTutorial.tutorial_id, 0.1
		@util.setCookie "oboardTutorialLastBox", @currentTutorial.boxes[@currentBoxId - 1].order_id, 0.1
	removeTutorialCookie: ->
		@util.setCookie "oboardTutorial","",-1
		@util.setCookie "oboardTutorialLastBox","",-1
	hooks:
		hooksBefore: {}
		hooksAfter: {}
		createHookBefore: (tutorialId,boxIndex,hook) ->
			hooksBefore.push
				tutorial: tutorialId
				box: boxIndex
				hook: hook
		createHookAfter: (tutorialId,boxIndex,hook) ->
			hooksAfter.push
				tutorial: tutorialId
				box: boxIndex
				hook: hook
		callHookBefore: (box) ->
			for hookObject in @hooksBefore
				if hookObject.tutorial is OBoard.currentTutorial and hookObject.box is OBoard.currentBoxId
					hookObject.hook box	
		callHookAfter: ->
			for hookObject in @hooksAfter
				if hookObject.tutorial is OBoard.currentTutorial and hookObject.box is OBoard.currentBoxId
					hookObject.hook()

	ui:
		initialize: (tutorials,boxesHtml,extrasHtml,menuItemHtml, menuData)->
			@menu.initialize tutorials,menuItemHtml, menuData
			@boxRenderer.initialize boxesHtml,extrasHtml
		renderBox: (box) ->
			boxClass = @boxRenderer.createBox box.type,box.bound_id,box.text,box.data
			for name,data of box.extras
				extra = @boxRenderer.createExtra name,data
				boxClass.extra extra
			boxClass.render()

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
			initialize: (tutorials,menuItemHtml,data) ->
				@menuItemHtml = menuItemHtml
				@buildGraphics data

				$("#oboard-menubutton-outer").click =>
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
				$("#oboard-menubutton-outer").bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
					if @menuVisible
						$("#oboard-menubutton-outer").hide()
				$(@closeTutorialButton).bind "transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd", =>
					unless OBoard.inTutorial()
						$(@closeTutorialButton).hide()
				@addTutorial key for key,value of tutorials

				@hideCloseTutorialButton()
				@hideMenu()
				@hideMenuButton()
			buildGraphics: (data) ->
				$(@menuButton).css "background-color", data.buttonColor
				if data.buttonHeader?
					$(".oboard-menubutton-header").text data.buttonHeader
				else
					$(".oboard-menubutton-header").remove()
					$(@menuButton).removeClass "oboard-menubutton-w-header"
					$(@menuButton).addClass "oboard-menubutton"
				$(".oboard-menu-header").text data.menuHeader
				$("#oboard-menu-header, #oboard-menu-close").css "background-color", data.detailsBackground
			hideMenuButton: ->
				$(".oboard-menubutton-outer").addClass "oboard-menubutton-hidden"
			showMenuButton: ->
				$(".oboard-menubutton-outer").show 
					complete: =>
						$(".oboard-menubutton-outer").removeClass "oboard-menubutton-hidden"
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
					OBoard.downloadTutorialData OBoard.tutorials[tutorial], (tutorialData)->
						OBoard.loadTutorial tutorialData
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
						OBoard.hooks.callHookBefore @
						OBoard.ui.boxRenderer.activeBoxes.push @
						$element = @element()
						@appendExtras $element
						@appendToParent $element
						OBoard.hooks.callHookAfter()
						$element
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
						console.log jbox.find ".oboard-box"
						$(jbox.get(0)).offset
							top: @data.y
							left: @data.x
						jbox
					render: ->
						$element = super()
						switch @data.arrow_side
							when 0
								$element.find(".oboard-box-arrow-before")
										.addClass("oboard-box-arrow-top")
										.addClass("oboard-box-arrow-before-top")
								$element.find(".oboard-box-arrow-after")
										.addClass("oboard-box-arrow-top")
										.addClass("oboard-box-arrow-after-top")
							when 1
								$element.find(".oboard-box-arrow-before")
										.addClass("oboard-box-arrow-right")
										.addClass("oboard-box-arrow-before-right")
								$element.find(".oboard-box-arrow-after")
										.addClass("oboard-box-arrow-right")
										.addClass("oboard-box-arrow-after-right")
							when 2
								$element.find(".oboard-box-arrow-before")
										.addClass("oboard-box-arrow-bottom")
										.addClass("oboard-box-arrow-before-bottom")
								$element.find(".oboard-box-arrow-after")
										.addClass("oboard-box-arrow-bottom")
										.addClass("oboard-box-arrow-after-bottom")
							when 3
								$element.find(".oboard-box-arrow-before")
										.addClass("oboard-box-arrow-left")
										.addClass("oboard-box-arrow-before-left")
								$element.find(".oboard-box-arrow-after")
										.addClass("oboard-box-arrow-left")
										.addClass("oboard-box-arrow-after-left")
							else
								throw new Error "Invalid arrow side"
						$('html, body').animate
							scrollTop: OBoard.util.calculateScrollToCenter $(".oboard-box")
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
	util:
		bubbleSort: (list) ->
			for i in [0...list.length]
				console.log i
				for j in [0...list.length]
					console.log j
					if list[j].order_id > list[i].order_id
		 				[list[j], list[i]] = [list[i], list[j]]
			list
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

		setCookie: (cname, cvalue, exhours) ->
			date = new Date()
			date.setTime date.getTime() + (exhours*60*60*1000)
			expires = "expires="+date.toUTCString()
			document.cookie = cname + "=" + cvalue + "; " + expires+"; path=/"

		getCookie: (cname) ->
			name = "#{cname}="
			ca = document.cookie.split ";"
			for cookie in ca
				while cookie.charAt(0) is ' '
					cookie = cookie.substring 1 
				return cookie.substring(name.length,cookie.length) unless cookie.indexOf(name) is -1
			return ""