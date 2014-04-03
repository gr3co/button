var Coord = require('mongoose').model('Coord'),
_ = require('underscore');

module.exports = function(app) {

	app.get('/api/getBoners', function(req,res){
		if (req.headers["user-agent"].indexOf("Button") < 0){
			return res.json({
				status: 403,
				type: "coords_err",
				data: "Device forbidden."
			});
		}
		else if (!req.query.idnum){
			return res.json({
				status: 500,
				type: "coords_err",
				data: "No identifier provided."
			});
		}
		else if (!req.query.lat || !req.query.lng){
			return res.json({
				status: 500,
				type: "coords_err",
				data: "Please provide valid coordinates."
			});
		}
		else if (!req.query.rad){
			return res.json({
				status: 500,
				type: "coords_err",
				data: "Please provide valid radius."
			});
		}
		var lat = parseFloat(req.query.lat);
		var lng = parseFloat(req.query.lng);
		var rad = parseFloat(req.query.rad);
		var now = new Date();
		var earliest = now - 1000 * 60 * 60 * 24;
		Coord.lookupByRadiusAndAge(lat,lng,rad, earliest, function(err, coords){
			if (err){
				return res.json({
					status: 500,
					type: "coards_err",
					data: "There was an error loading coordinates."
				});
			}
			else return res.json({
					status:200,
					type: "coords_ok",
					data: _.map(coords, function(val){
						return {
							lng : val.coords[0],
							lat : val.coords[1],
							age : val.timestamp.valueOf()
						}})
			});
		});
	});

	app.post('/api/sendLocation', function(req,res){
		if (req.headers["user-agent"].indexOf("Button") < 0){
			return res.json({
				status: 403,
				type: "save_err",
				data: "Device forbidden."
			});
		}
		else if (!req.body.idnum){
			return res.json({
				status: 500,
				type: "save_err",
				data: "No identifier provided."
			});
		}
		else if (!req.body.lat || !req.body.lng){
			return res.json({
				status: 500,
				type: "save_err",
				data: "Please provide valid coordinates."
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
						type: "save_err",
						data: "There was an error saving coordinates."
					});
				}
				else return res.json({
					status: 200,
					type: "save_ok",
					data: "Location successfully saved."
				});
		});
	});
};