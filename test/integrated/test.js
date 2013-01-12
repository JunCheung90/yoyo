var restify, should, yoyoConfig, client, can;
restify = require('restify');
should = require('should');
yoyoConfig = {
  url: 'http://localhost:8888',
  version: '~1.0'
};
client = restify.createJsonClient(yoyoConfig);
can = it;
describe('测试YoYo REST API', function(){
  can('查询联系人：GET /contact/10879 应当返回200', function(done){
    client.get('/contact/10879', function(err, req, res, data){
      should.not.exist(err);
      res.statusCode.should.eql(200);
      done();
    });
  });
  can('注册用户：POST /user 应当返回200', function(done){
    var postData;
    postData = require('./zhangsan.json');
    client.post('/user', postData, function(err, req, res, data){
      should.not.exist(err);
      res.statusCode.should.eql(200);
      done();
    });
  });
});