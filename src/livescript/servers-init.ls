require! [restify, './config/config'.mongo, 
					'mongodb'.MongoClient, 'mongodb'.Server]

init-mongo-client = !(callback) -> #mongo-client, db are used to return
	mongo-client = new MongoClient new Server mongo.host, mongo.port
	(err, client) <-! mongo-client.open
	db = mongo-client.db(mongo.db)
	db.users = db.collection 'users'
	callback mongo-client, db

shutdown-mongo-client = !(mongo-client, callback) ->
	mongo-client.close!
	callback!

(exports ? this) <<< {init-mongo-client, shutdown-mongo-client}