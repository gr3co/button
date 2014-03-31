module.exports = function(app) {

	app.post('/api/sendLocation', function(req,res){
		console.log(req.params);
		return res.json({
			status: 200,
			message: "Thanks"
		});
	});

};