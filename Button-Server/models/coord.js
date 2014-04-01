var mongoose = require('mongoose'),
  Schema = mongoose.Schema;

var coordSchema = new Schema({
  identifier : String,
  coords: {type: [Number], index: '2d'},
  timestamp : Date
});

coordSchema.statics.lookupByRadius = function(lat, lon, radius, next){
  this.find({coords: {$geoWithin : {$center : [[lon, lat], radius]}}}).exec(next);
};

module.exports = mongoose.model('Coord', coordSchema, 'boners');