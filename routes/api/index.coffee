commands = require "./commands"
module.exports.expressGet = (req,res,next) ->
	command = commands.get[req.param "command"]
	if command?
		# Run user verification
		req.models.users.one
			pub_id: req.param "userSecret"
		, (err,user) ->
			unless user?
				res.json
					success: false
					message: "Invalid user secret"
			else unless req.param "host" in user.hosts
				res.json
					success: false
					message: "Host not permitted access by user"
			else
				command req,user, (success,data) ->
					res.json
						success: success
						data: data
	else
		res.json 
			success: false
			message: "Command not found"
module.exports.expressPost = (req,res,next) ->
