commands = require "./commands"
module.exports.expressGet = (req,res,next) ->
	command = commands.get[req.param "command"]
	if command?
		command req, (success,data) ->
			res.json
				success: success
				data: data
	else
		res.json 
			success: false
			message: "Command not found"
module.exports.expressPost = (req,res,next) ->
