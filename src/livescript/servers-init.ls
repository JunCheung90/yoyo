/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [restify, './config/config'.mongo, 
					'mongodb'.MongoClient, 'mongodb'.Server]
fqi = require './fast-query-index'

init-mongo-client = !(callback) -> #mongo-client, db are used to return
	mongo-client = new MongoClient new Server mongo.host, mongo.port
	(err, client) <-! mongo-client.open
	db = mongo-client.db(mongo.db)
	db.users = db.collection 'users'
	db.call-logs = db.collection 'call-log-statistic'
	# <- fqi.init-communication-channels-maps db
	callback mongo-client, db

shutdown-mongo-client = !(mongo-client, callback) ->
	mongo-client.close!
	callback!

(exports ? this) <<< {init-mongo-client, shutdown-mongo-client}