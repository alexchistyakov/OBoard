module.exports = 
	get:
		"load-tutorial": (req,callback)->
			unless req.params.tutorial_id?
				callback false, 
					message: "tutorial_id not provided"
			else
				req.models.tutorials.exists
					pub_id: tutorial_id
				, (err, exists) ->
					if err or not exists
						callback false,
							message: "No tutorial matches id"
					req.models.tutorials.one
						pub_id: tutorial_id
					, (err, tutorial) ->
						if req.params.host is not tutorial.host
							callback false, "Tutorial is bound to another host"
						req.models.users.one
							pub_id: req.params.userSecret
						, (err,user) ->
							unless tutorial.owner_id is user.id
								callback false, "User secret invalid or tutorial does not belong to user"
							if err
								callback false, err.message
							else
								res ={ 
									name: tutorial.name
									assets:
										css: $.map req.css.renderTags("tutorial").split("\n"), (stylesheet) ->
			                                if stylesheet?
			                                    req.server + $(stylesheet).attr "href"
				                        js: $.map req.js.renderTags("tutorial").split("\n"), (script) ->
				                                if script?
				                                    req.server + $(script).attr "src"
									boxes: []
				                }
								boxes = tutorial.getBoxes()
								fromBox = req.params.from_box or 0
								toBox = req.params.to_box or boxes.length
								for i in [fromBox..toBox]
									element = 
										order_id: box.order_id
										text: box.text
										bound_id: box.bound_id
										popup: box.popup
									res.boxes.push element
								callback true, res