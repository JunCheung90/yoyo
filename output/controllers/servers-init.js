var restify, sequelize, mysql, config, couch, orm, mysqlConnection, root;
restify = require('restify');
sequelize = require('sequelize');
mysql = require('mysql');
config = require('../config/config');
couch = restify.createJsonClient(config.couch);
orm = new sequelize('test_sequelize', 'yoyo', 'yoyo');
mysqlConnection = mysql.createConnection(config.mysql);
root = typeof exports != 'undefined' && exports !== null ? exports : this;
root = {
  couch: couch,
  orm: orm,
  mysqlConnection: mysqlConnection
};