commands = require "./commands"
module.exports.expressGet = (req,res,next) ->
	command = commands.get[req.param "command"]
	if command?
		# Run user verification
		req.models.users.one
			pub_id: req.param "userSecret"
		, (err,user) ->
			if not user? and err?
				res.json
					success: false
					message: "Invalid user secret"
			else 
				req.models.projects.one 
					pub_id: req.param "project_id"
					owner_id: user.id
				, (err,project) ->
					unless project?
						res.json 
							success: false
							message: "Project not found or does not belong to user"
					else
						command req,user,project (success,data) ->
							res.json
								success: success
								data: data
	else
		res.json 
			success: false
			message: "Command not found"
module.exports.expressPost = (req,res,next) ->
