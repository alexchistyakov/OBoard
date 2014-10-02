express = require 'express'
authPage = require "./auth"
authHandler = require "./auth/authentication"
api = require "./api"
purchase = require "./purchase"
router = express.Router();

# GET home page. 
router.get '/', (req, res) ->
  res.render 'index',
  	title: false
  	isAuthenticated: req.isAuthenticated()
  	user: req.user
  	js: req.coffee.renderTags "home"
  	css: req.css.renderTags "home"

router.get "/api", api.expressGet
router.post "/api", api.expressPost

router.get "/login", authPage.loginPage
router.post "/login", authHandler.authenticateLogin

router.get "/register", authPage.registerPage
router.post "/register", authHandler.authenticateRegister

router.get "/logout", authHandler.logout

router.get "/purchase", purchase

module.exports = router

