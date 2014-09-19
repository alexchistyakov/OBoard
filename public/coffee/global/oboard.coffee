window.OBoard = 
	$$: document.querySelectorAll.bind document
	currentTutorial: null
	currentBoxId: null
	oboardUrl: "//localhost/api"
	oboardRequest: (params, action, callback) ->
        xhr = null
        full_url = oboardUrl
        full_params = ""

        params.userSecret = script.getAttribute "user-secret" 
        params.host = window.location.hostname
        params.path = window.location.pathname
        params.port = window.location.port

        for key in params
            unless full_params is ""
                full_params += "&"

            if params[key]?
                full_params += key + "=" + encodeURIComponent params[key]

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
                    xhr = new ActiveXObject(versions[i]);
                    break;
                catch e
                    return callback(false);
        
        xhr.onreadystatechange = ->
            if xhr.readyState < 4 or xhr.status is not 200
                return callback false
            else if xhr.readyState is 4
                return callback xhr.response
            else
                return callback false
            

        xhr.withCredentials = true;
        xhr.open(action, full_url, true);
        xhr.responseType = "json";

        unless action is "GET"
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

        xhr.send(full_params);

	loadTutorial: (pub_id,callback) ->
		oboardRequest {
            command: "load-tutorial"
			tutorialId: pub_id
		}, "GET", (response) ->
            currentTutorial = response.data
		    currentBoxId = -1

	    	data.css.forEach (href) ->
	    		link = document.createElement "link"
	    		link.href = href
	    		link.rel = "stylesheet"
	    		document.head.appendChild link
	    	data.js.forEach (src) ->
	    		link = document.createElement "script"
	    		script.src = src;
	    		script.type = "text/javascript"
	    		document.head.appendChild script

			callback()

	unloadTutorial: ->
		currentTutorial = null
		currentBoxId = null

	startTutorial: ->
		currentBoxId = script.getAttribute "frombox"

    nextBox: ->
        unless currentTutorial.boxes[currentBoxId+1]?
            throw new Error "No more boxes"
        else 
            # Remove previous box here TODO
            boundElement = document.getElementById currentTutorial.bound_id
            unless boundElement?
                throw new Error "Bound element not found or didn't appear yet"
            else 
                box = document.createElement("div")
                box.class = "oboard_box"
                box.id = "oboard_tutorial_box"

                boundElement.appendChild box

