var _ = require('underscore'),
  passport = require('passport');

// use for routes that require authentication; user is automatically
// added to handlebars vars.
function requireAuth(req, res, next) {
  if (!req.isAuthenticated()) {
    req.flash('error', 'Please log in or register.');
    return res.redirect('/');
  }
  res.locals.user = req.user;
  return next();
}

// populates handlebars local vars with user, if logged in.
function optionalAuth(req, res, next) {
  if (req.isAuthenticated()) {
    res.locals.user = req.user;
  }
  return next();
}

module.exports = function(app) {

  require('./api')(app);

  app.get('/', optionalAuth, function(req, res) {
    var texts = [

    ];
    var text = texts[Math.floor(Math.random() * texts.length)];
    res.render('home', {text: text, errors: req.flash('error')});
  });
};