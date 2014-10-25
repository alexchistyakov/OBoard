module.exports = (req,res,next) ->
	###req.models.tutorials.create
		project_id: 1
		name: "Test"
	,(err) ->
		console.log err###

	req.models.boxes.create
		tutorial_id: 1
		text: "This is the calendar where all your activities are shown"
		order_id: 0
		type: "boxsimple"
		bound_id: "content"
		x: "205"
		y: "350"
		arrow_side: 3
		bound_path: "/Users/Alex/Documents/OBoard%20Test/Haiku%20Learning%20%20%20Portal%20%20%20Alexander.html"
		extras:
			header:
				text: "Calendar"
			okbutton:
				{}
		,(err) ->
			console.log err

	req.models.boxes.create
		tutorial_id: 1
		text: "Here are your weekly activities and homework"
		order_id: 0
		type: "boxsimple"
		bound_id: "content"
		x: "504"
		y: "350"
		arrow_side: 3
		bound_path: "/Users/Alex/Documents/OBoard%20Test/Haiku%20Learning%20%20%20Portal%20%20%20Alexander.html"
		extras:
			okbutton:
				{}
	,(err) ->
		console.log err
	###req.models.projects.create
		owner_id: 1
		name: "Localhost"
		host: "http://localhost"
	, (err) ->
		console.log err###