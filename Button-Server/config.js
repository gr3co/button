var _ = require('underscore'),

global = {
  root: __dirname,
  app: {
    name: 'button-server'
  },
  port: 3000
};

development = {
  db: {
    db: 'button-dev',
    host: '127.0.0.1'
  },
  cookie: {
    secret: 'development',
    maxAge: 1000 * 60 * 60 * 24 * 7
  },
  socket: {
    logLevel: 2
  }
};

test = {
  db: {
    db: 'button-test',
    host: '127.0.0.1'
  },
  cookie: {
    secret: 'testing',
    maxAge: 1000 * 60 * 60 * 24 * 7
  },
  socket: {
    logLevel: 1
  }
};

production = {
  db: {
    db: 'button',
    host: '127.0.0.1'
  },
  cookie: {
    secret: 'r0r0suxc0ck',
    maxAge: 1000 * 60 * 60 * 24 * 7
  },
  socket: {
    logLevel: 0
  }
};


module.exports = {
  development: _.extend({}, global, development),
  test: _.extend({}, global, test),
  production: _.extend({}, global, production)
};