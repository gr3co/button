var Coord = require('mongoose').model('Coord');

module.exports = function(app) {

	app.get('/api/sendLocation', function(req,res){
	});

	app.post('/api/sendLocation', function(req,res){
		console.log(req.body);
		if (req.headers["user-agent"].indexOf("Button") < 0){
			return res.json({
				status: 403,
				message: "Device forbidden."
			});
		}
		else if (!req.body.idnum){
			return res.json({
				status: 500,
				message: "No identifier provided."
			});
		}
		else if (!req.body.lat || !req.body.lng){
			return res.json({
				status: 500,
				message: "Please provide valid coordinates."
			});
		}
		Coord.findOneAndUpdate(
			{identifier : req.body.idnum},
			{coords : [req.body.lng, req.body.lat],
			timestamp : new Date()},
			{upsert : true},
			function (err){
				if (err){
					return res.json({
						status: 500,
						message: "There was an error saving coordinates."
					});
				}
				else return res.json({
					status: 200,
					message: "Location successfully saved."
				});
		});
	});
};