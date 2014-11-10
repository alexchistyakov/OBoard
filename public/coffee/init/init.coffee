((window,document) =>
	oboardRootUrl = "http://localhost"
	oboardXHRRequest = (params, action, callback,url) ->
		xhr = null
		full_url = url
		full_params = ""

		for key,value of params
			unless full_params is ""
				full_params += "&"
			if value?
				full_params += "#{key}=#{encodeURIComponent value}"

		if action is "GET"
			full_url += "?" + full_params

		if XMLHttpRequest?
			xhr = new XMLHttpRequest()
		else
			versions = [
				"MSXML2.XmlHttp.5.0",
				"MSXML2.XmlHttp.4.0",
				"MSXML2.XmlHttp.3.0",
				"MSXML2.XmlHttp.2.0",
				"Microsoft.XmlHttp"
			]

			for i in [0..versions.length]
				try
					xhr = new ActiveXObject versions[i]
					break
				catch e
					return callback false
		
		xhr.onreadystatechange = ->
			if xhr.readyState < 4 or xhr.status is not 200
				return callback false
			else if xhr.readyState is 4
				if typeof xhr.response is "string"
					callback JSON.parse xhr.response
				else
					callback xhr.response
			else
				return callback false
			

		xhr.withCredentials = true;
		xhr.open(action, full_url, true);
		xhr.responseType = "json";

		unless action is "GET"
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

		xhr.send(full_params);

	element = document.getElementById "oboard-js"
	oboardUrl = "#{oboardRootUrl}/api"
	oboardRequest = (params, action, callback) =>
		params.userSecret = element.getAttribute "data-key"
		params.project_id = element.getAttribute "project-id"
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
				if window.OBoard? and $("body")?
					$("body").append response.data.content
					clearInterval interval	
					window.OBoard.init response.data.oboard,oboardRequest,element,oboardUrl
			, 10
)(window,document)