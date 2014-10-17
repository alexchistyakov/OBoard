module.exports = (req,res,next) ->
	###req.models.tutorials.create
		project_id: 1
		name: "Test"
	,(err) ->
		console.log err###

	req.models.boxes.create
		tutorial_id: 1
		header: "Hello, I am a box"
		text: "Hello world"
		order_id: 0
		type: "boxsimple"
		bound_id: ""
		x: "100"
		y: "100"
		arrow_side: 3
		bound_path: "/Users/Alex/Documents/test/index2.html"
	,(err) ->
		console.log err

	###req.models.projects.create
		owner_id: 1
		name: "Localhost"
		host: "http://localhost"
	, (err) ->
		console.log err###