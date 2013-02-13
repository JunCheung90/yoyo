/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [restify, './config/config'.mongo, 
          'mongodb'.MongoClient, 'mongodb'.Server, './util', './database', './models/User']
fqh = require './fast-query-helper'

init-mongo-client = !(callback) -> #mongo-client, db are used to return
  database.client = new MongoClient new Server mongo.host, mongo.port
  (err, client) <-! database.client.open
  database.db = database.client.db(mongo.db)
  database.db.users = database.db.collection 'users'
  database.db.call-logs = database.db.collection 'call-log-statistic'
  # util.event.on 'user-info-updated', User.user-info-updated-handler
  callback!

shutdown-mongo-client = !(callback) ->
  database.client.close!
  callback!

(exports ? this) <<< {init-mongo-client, shutdown-mongo-client}