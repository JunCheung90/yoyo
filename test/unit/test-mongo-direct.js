var should, async, MongoClient, Server, initMongoClient, shutdownMongoClient, ref$, db, client, can;
should = require('should');
async = require('async');
MongoClient = require('mongodb').MongoClient;
Server = require('mongodb').Server;
initMongoClient = require('../../src/servers-init').initMongoClient;
shutdownMongoClient = require('../../src/servers-init').shutdownMongoClient;
ref$ = [null, null], db = ref$[0], client = ref$[1];
can = it;
describe('MongoDB 用法', function(){
  before(function(done){
    initMongoClient(function(mongoClient, mongoDb){
      var ref$;
      ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
      done();
    });
  });
  can('创建User张三', function(done){
    checkCreateUserWith('zhangsan.json', '张三', done);
  });
  after(function(done){
    shutdownMongoClient(client, function(){
      done();
    });
  });
});
function checkCreateUserWith(jsonFileName, userName, callback){
  var userData;
  userData = require("../test-data/" + jsonFileName);
  db.collection('users').insert(userData, function(err, result){
    should.not.exist(err);
    return callback();
  });
}