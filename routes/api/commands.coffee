fs = require "fs"
module.exports = 
	get:
		"load-essentials": (req,user,callback)->
			req.models.tutorials.find
				owner_id: user.id
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
				resBoxesHtml = {}
				for path in fs.readdirSync "#{__dirname}/../../views/boxes"
					name = path.substring 0, path.indexOf "."
					req.app.render "boxes/#{name}", {}, (error,content) ->
						resBoxesHtml[name] = content

				callback true,
					oboard:
						tutorials: resTutorials
						boxesHtml: resBoxesHtml
					assets:
						js: resJs
						css: resCss
					content: resHtml
				

		"load-tutorial": (req,user,callback)->
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
							else unless tutorial.owner_id is user.id
								callback false, "Tutorial does not belong to user"
							else if err
								callback false, err.message
							else
								res =
									name: tutorial.name
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
											popup: box.popup
											next_button: box.next_button
											arrow_side: box.arrow_side
											type: box.type
										res.boxes.push element
									callback true, res