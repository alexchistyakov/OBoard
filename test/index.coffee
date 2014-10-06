module.exports = (req,res,next) ->
	req.models.tutorials.create
		project_id: 1
		name: "Test"
	,(err) ->
		console.log err

	req.models.boxes.create
		tutorial_id: 1
		text: "Hello world"
		order_id: 0
		type: "simple"
		x: "100"
		y: "100"
		arrow_side: 3
		bound_path: "/"
	,(err) ->
		console.log err

	req.models.projects.create
		owner_id: 1
		name: "Localhost"
		host: "http://localhost"
	, (err) ->
		console.log err