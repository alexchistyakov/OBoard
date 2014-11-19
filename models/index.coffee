orm = require "orm"
config = require "../config"
async = require "async"
init = false
dbModels = null
module.exports.express = orm.express config.database, 
	define: (db,models,callback) ->
		dbModels = models
		models.tutorials = require("./tutorials")(db,models)
		models.boxes = require("./tutorials/boxes")(db,models)
		models.users = require("./users")(db,models)
		models.projects = require("./projects")(db,models)
		models.menus = require("./menus")(db,models)

		models.boxes.hasOne "tutorial",models.tutorials, 
			reverse : "boxes"

		models.projects.hasOne "owner",models.users,
			reverse : "projects"
		
		models.tutorials.hasOne "project",models.projects,
			reverse: "tutorials"
		
		models.menus.hasOne "project",models.projects,
			reverse: "menu"

		unless init
			async.series [
				(next) =>
					if config.database.reset
						db.drop next
					else
						next()
				(next) =>
					if config.database.reset or config.database.sync
						db.sync next
					else
						next()
			], (errors) =>
				init = true
				callback() if callback?
		else
			callback() if callback?
module.exports.model = (name) ->
	dbModels[name]