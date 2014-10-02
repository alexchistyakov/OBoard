((window,document) ->
	element = document.getElementById "oboard-js"
	oboardUrl = "#{oboardRootUrl}/api"
	oboardRequest = (params, action, callback) ->
		params.userSecret = element.getAttribute "data-key"
		params.host = window.location.hostname
		params.path = window.location.pathname
		params.port = window.location.port
		oboardXHRRequest params,action,callback,oboardUrl
	
	oboardRequest
		command: "load-essentials"
	, "GET", (response) ->
		unless response is false
			response.data.assets.css.forEach (href) ->
				link = document.createElement "link"
				link.href = href
				link.rel = "stylesheet"
				document.head.appendChild link
			response.data.assets.js.forEach (src) ->
				script = document.createElement "script"
				script.src = src;
				script.type = "text/javascript"
				document.head.appendChild script
			interval = setInterval ->
				if window.OBoard? and $?
					$("body").append response.data.content
					clearInterval interval	
					window.OBoard.init response.data.oboard,oboardRequest,element,oboardUrl
			, 10
)(window,document)