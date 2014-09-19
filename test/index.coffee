module.exports = (req,res,next) ->
	req.models.tutorials.create
		owner_id: 1
		name: "Test"
		host: "localhost"
	,(err) ->
		console.log err

	req.models.boxes.create
		tutorial_id: 1
		text: "Hello world"
		order_id: 0
		popup: false
		bound_id: "crazy-div"
	,(err) ->
		console.log err