module.exports = (req,res,next) ->
	###req.models.tutorials.create
		project_id: 1
		name: "Haiku Overview"
		bound_path: "/Users/Alex/Documents/OBoard%20Test/Haiku%20Learning%20%20%20Portal%20%20%20Alexander.html"
	,(err) ->
		console.log err
	###
	###req.models.boxes.create
		tutorial_id: 1
		text: "This tutorial will show you an overview of your Haiku page"
		order_id: 0
		type: "boxpopup"
		bound_id: null
		x: "0"
		y: "0"
		arrow_side: 3
		bound_path: "/Users/Alex/Documents/OBoard%20Test/Haiku%20Learning%20%20%20Portal%20%20%20Alexander.html"
		extras:
			okbutton:
				{}
		,(err) ->
			console.log err

	req.models.boxes.create
		tutorial_id: 1
		text: "This is the calendar where all your activities are shown"
		order_id: 1
		type: "boxsimple"
		bound_id: "col_2"
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
		order_id: 2
		type: "boxsimple"
		bound_id: "col_2"
		x: "504"
		y: "350"
		arrow_side: 3
		bound_path: "/Users/Alex/Documents/OBoard%20Test/Haiku%20Learning%20%20%20Portal%20%20%20Alexander.html"
		extras:
			okbutton:
				{}
	,(err) ->
		console.log err
		###
	req.models.boxes.create
		tutorial_id: 1
		text: "Just a random test box"
		order_id: 3
		type: "boxpopup"
		bound_id: null
		x: 0
		y: 0
		arrow_side: 0
		bound_path: "/Users/Alex/Documents/OBoard%20Test/foundation.html"
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