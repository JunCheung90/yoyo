var restify, mongo, MongoClient, Server, initMongoClient, shutdownMongoClient, ref$;
restify = require('restify');
mongo = require('./config/config').mongo;
MongoClient = require('mongodb').MongoClient;
Server = require('mongodb').Server;
initMongoClient = function(callback){
  var mongoClient;
  mongoClient = new MongoClient(new Server(mongo.host, mongo.port));
  mongoClient.open(function(err, client){
    var db;
    db = mongoClient.db(mongo.db);
    db.users = db.collection('users');
    callback(mongoClient, db);
  });
};
shutdownMongoClient = function(mongoClient, callback){
  mongoClient.close();
  callback();
};
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.initMongoClient = initMongoClient;
ref$.shutdownMongoClient = shutdownMongoClient;