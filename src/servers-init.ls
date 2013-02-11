/*
 * Created by Wang, Qing. All rights reserved.
 */

require! [restify, './config/config'.mongo, 
          'mongodb'.MongoClient, 'mongodb'.Server, './util', './models/User']
fqh = require './fast-query-helper'

init-mongo-client = !(callback) -> #mongo-client, db are used to return
  mongo-client = new MongoClient new Server mongo.host, mongo.port
  (err, client) <-! mongo-client.open
  db = mongo-client.db(mongo.db)
  db.users = db.collection 'users'
  db.call-logs = db.collection 'call-log-statistic'
  # <- fqh.init-communication-channels-maps db
  util.event.on 'user-info-updated', User.re-evaluate-user-pending-mergences
  callback mongo-client, db

shutdown-mongo-client = !(mongo-client, callback) ->
  mongo-client.close!
  callback!

(exports ? this) <<< {init-mongo-client, shutdown-mongo-client}