require! [restify, sequelize, mysql, '../config/config']

couch = restify.create-json-client config.couch
orm = new sequelize ...config.sequelize
mysql-connection = mysql.create-connection config.mysql
S = sequelize

(exports ? this) <<< {couch, orm, mysql-connection, S}