var restify, sequelize, mysql, config, couch, orm, mysqlConnection, S, ref$;
restify = require('restify');
sequelize = require('sequelize');
mysql = require('mysql');
config = require('../config/config');
couch = restify.createJsonClient(config.couch);
orm = new sequelize('test_sequelize', 'yoyo', 'yoyo');
mysqlConnection = mysql.createConnection(config.mysql);
S = sequelize;
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.couch = couch;
ref$.orm = orm;
ref$.mysqlConnection = mysqlConnection;
ref$.S = S;