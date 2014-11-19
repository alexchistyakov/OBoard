fs = require "fs"
module.exports = 
	get:
		"load-essentials": (req,user,project,callback)->
			req.models.menus.one
				project_id: project.id
			, (err, menu) ->
				req.models.tutorials.find
					project_id: project.id
					bound_path: req.param "path"
				, (err,tutorials) ->
					resTutorials = []
					for tutorial in tutorials
						resTutorials.push
							name: tutorial.name
							tutorial_id: tutorial.pub_id
					resJs = $.map req.coffee.renderTags("oboard").split("\n"), (script) ->
						if script? and not not $(script).attr("src")
							src = $(script).attr "src"
							if src.startsWith "http"
								src
							else
								req.protocol+"://"+req.hostname + src
					resCss = $.map req.css.renderTags("oboardclient").split("\n"), (stylesheet) ->
						if stylesheet? and not not $(stylesheet).attr("href")
							href = $(stylesheet).attr "href"
							if href.startsWith "http"
								href
							else
								req.protocol+"://"+req.hostname + href
					resHtml = null
					req.app.render "oboardclient/menu", {}, (error,content) ->
						resHtml = content
					resMenuItemHtml = null
					req.app.render "oboardclient/element", {}, (error,content)->
						resMenuItemHtml = content
					resBoxesHtml = {}
					for path in fs.readdirSync "#{__dirname}/../../views/boxes"
						name = path.substring 0, path.indexOf "."
						req.app.render "boxes/#{name}", {}, (error,content) ->
							resBoxesHtml[name] = content

					resExtrasHtml = {}
					for path in fs.readdirSync "#{__dirname}/../../views/boxes/extras"
						name = path.substring 0, path.indexOf "."
						req.app.render "boxes/extras/#{name}", {}, (error,content) ->
							resExtrasHtml[name] = content
					
					callback true,
						oboard:
							tutorials: resTutorials
							boxesHtml: resBoxesHtml
							extrasHtml: resExtrasHtml
							menuItemHtml: resMenuItemHtml
							menuData:
								buttonColor: if menu? then menu.button_color else null
								buttonHeader: if menu? then menu.button_header else null
								menuHeader: if menu? then menu.menu_header else null
								detailsBackground: if menu? then menu.details_background else null
						assets:
							js: resJs
							css: resCss
						content: resHtml
				

		"load-tutorial": (req,user,project,callback)->
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
							if req.param "host" is not project.host
								callback false, "Tutorial is bound to another host"
							else unless tutorial.project_id is project.id
								callback false, "Tutorial does not belong to project"
							else if err
								callback false, err.message
							else
								req.models.boxes.findByTutorial(tutorial).count (err,count) ->
									if err 
										callback false, err.message
									else
										res =
											name: tutorial.name
											tutorial_id: tutorial.pub_id
											boxes: []
										req.models.boxes.find
											tutorial_id: tutorial.id
											bound_path: req.param "path"
										, (err,boxes) ->
											for box in boxes
												element = 
													order_id: box.order_id
													text: box.text
													bound_id: box.bound_id
													data:
														x: box.x
														y: box.y
														arrow_side: box.arrow_side
													type: box.type
													extras: box.extras
												res.boxes.push element
											res.end = (boxes.last().order_id + 1) is count
											console.log (boxes.last().order_id + 1)
											console.log count
											callback true, res