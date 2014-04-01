var Coord = require('mongoose').model('Coord');

module.exports = function(app) {

	app.get('/api/sendLocation', function(req,res){
		if (req.headers["user-agent"].indexOf("Button") < 0){
			return res.json({
				status: 403,
				message: "Device forbidden."
			});
		}
		else if (!req.query.idnum){
			return res.json({
				status: 500,
				message: "No identifier provided."
			});
		}
		else if (!req.query.lat || !req.query.lng){
			return res.json({
				status: 500,
				message: "Please provide valid coordinates."
			});
		}
		var lat = parseFloat(req.query.lat);
		var lon = parseFloat(req.query.lng);
		var data = {
			identifier : req.query.idnum,
			coords : [lon, lat],
			timestamp : new Date()
		}
		var boner = new Coord(data);
		boner.save(function(err){
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