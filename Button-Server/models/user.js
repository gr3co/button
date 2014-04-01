var mongoose = require('mongoose')
  , Schema = mongoose.Schema
  , crypto = require('crypto');
 
var UserSchema = new Schema({
     username: String,
     first : String,
     last : String,
     email : String,
     userid: Number,
     pass: String,
     salt: String,
});

// password definition
UserSchema
    .virtual('password', String) 
    .set(function(password){
        this._password = password
        this.salt = this.generateSalt()
        this.pass = this.encryptPassword(password)
    })
    .get(function() {return this._password});

UserSchema.methods = {
  authenticate: function(passwd) {
    return this.encryptPassword(passwd) === this.pass;
  },

  generateSalt: function() {
    return Math.round((new Date().valueOf() * Math.random())) + '';
  },

  encryptPassword: function(passwd) {
    if (!passwd) return '';
    var e;
    try {
      e = crypto.createHmac('sha512', this.salt).update(passwd).digest('base64');
      for (var i = 0; i < 63; i++){
        e = crypto.createHmac('sha512', this.salt).update(e).digest('base64');
      }
      return e;
    }
    catch(err){
      return '';
    }
  }
}

UserSchema.statics = { 
  load: function (username, cb) {
    this.findOne({'username' : username}).exec(cb);
  },
  removeUser: function(username, cb) { 
    this.remove({'username' : username}).exec(cb);
  },
  exists: function(username,cb) {
    this.load(username, function(err,user) { 
      if(err) return false;
      if (user) cb(true);
      else cb(false);
    });
  },
} 

mongoose.model('User', UserSchema, 'users');