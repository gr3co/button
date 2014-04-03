module.exports = function(app) {

  require('./api')(app);

  app.get('/', function(req, res) {
    res.render('home', {title:"Boner Button"});
  });
};