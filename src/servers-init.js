var config = require('../config/config');

var restify = require('restify')
	, couch = restify.createJsonClient(config.couch);


var sequelize = require('sequelize')
	, orm = new sequelize('test_sequelize', 'yoyo', 'yoyo');


var mysql = require('mysql')
	, mysqlConnection = mysql.createConnection(config.mysql);


exports.couch = couch;
exports.sequelize = sequelize;
exports.orm = orm;
exports.mysqlConnection = mysqlConnection;

