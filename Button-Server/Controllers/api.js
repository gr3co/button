module.exports = function(app) {

	app.post('/api/sendLocation', function(req,res){
		return res.json({
			status: 200,
			body: req.body,
			params: req.params
		});
	});

};