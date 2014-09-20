module.exports = 
	get:
		"load-tutorial": (req,callback)->
			tutorial_id = req.param("tutorial_id")
			unless tutorial_id?
				callback false, 
					message: "tutorial_id not provided"
			else
				req.models.tutorials.exists
					pub_id: tutorial_id
				, (err, exists) ->
					if err or not exists
						callback false,
							message: "No tutorial matches id"
					else 
						req.models.tutorials.one
							pub_id: tutorial_id
						, (err, tutorial) ->
							if req.param "host" is not tutorial.host
								callback false, "Tutorial is bound to another host"
							else 
								req.models.users.one
									pub_id: req.param "userSecret"
								, (err,user) ->
									unless user?
										callback false, "Invalid user secret"
									else unless tutorial.owner_id is user.id
										callback false, "User secret invalid or tutorial does not belong to user"
									else if err
										callback false, err.message
									else
										res =
											name: tutorial.name
											assets:
												css: $.map req.css.renderTags("tutorial").split("\n"), (stylesheet) ->
													if stylesheet? and not not $(stylesheet).attr("href")
														href = $(stylesheet).attr "href"
														if href.startsWith "http"
															href
														else
															"http://"+req.hostname + href
												js: $.map req.coffee.renderTags("tutorial").split("\n"), (script) ->
													if script? and not not $(script).attr("src")
														src = $(script).attr "src"
														if src.startsWith "http"
															src
														else
															"http://"+req.hostname + src
											boxes: []
										console.log tutorial.getBoxes
										req.models.boxes.find
											tutorial_id: tutorial.id
										, (err,boxes) ->
											console.log boxes
											fromBox = req.param("frombox") || 0
											toBox = req.param("tobox") || boxes.length
											console.log boxes
											for i in [fromBox...toBox]
												element = 
													order_id: boxes[i].order_id
													text: boxes[i].text
													bound_id: boxes[i].bound_id
													popup: boxes[i].popup
												res.boxes.push element
											callback true, res