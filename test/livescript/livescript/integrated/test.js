var restify, should, orm, dropCreateOrm, yoyoConfig, client, can;
restify = require('restify');
should = require('should');
orm = require('../../src/servers-init').orm;
dropCreateOrm = require('../../src/orm-sync').dropCreateOrm;
yoyoConfig = {
  url: 'http://localhost:8888',
  version: '~1.0'
};
client = restify.createJsonClient(yoyoConfig);
can = it;
describe('测试YoYo REST API', function(){
  before(function(done){
    dropCreateOrm(function(){
      done();
    });
  });
  can('注册用户：POST /user 应当返回200', function(done){
    var postData;
    postData = require('../test-data/zhangsan.json');
    client.post('/user', postData, function(err, req, res, data){
      should.not.exist(err);
      res.statusCode.should.eql(200);
      done();
    });
  });
});