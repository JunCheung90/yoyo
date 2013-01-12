var restify, sequelize, mysql, config, couch, orm, mysqlConnection, S, ref$;
restify = require('restify');
sequelize = require('sequelize');
mysql = require('mysql');
config = require('./config/config');
couch = restify.createJsonClient(config.couch);
orm = (function(func, args, ctor) {
  ctor.prototype = func.prototype;
  var child = new ctor, result = func.apply(child, args), t;
  return (t = typeof result)  == "object" || t == "function" ? result || child : child;
  })(sequelize, config.sequelize, function(){});
mysqlConnection = mysql.createConnection(config.mysql);
S = sequelize;
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.couch = couch;
ref$.orm = orm;
ref$.mysqlConnection = mysqlConnection;
ref$.S = S;