module.exports = (req,res,next) ->
	unless req.user?
		res.render "purchase/notloggedin"
	else
		res.render "purchase/index",
			title: "Purchase"
			js: req.coffee.renderTags "purchase"
			css: req.css.renderTags "purchase"