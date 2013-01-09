var restify = require('restify')
  , should = require('should');

var client = restify.createJsonClient({
  url: 'http://localhost:8888',
  version: '~1.0'
});

describe('REST API',function(){

  // before(function(done){
  //   http.createServer(server,done);
  // });

  it('查询某个联系人：GET /contact/10879 应当返回200', function(done){
    client.get('/contact/10879', function(err, req, res, data){
      should.not.exist(err);
      res.statusCode.should.eql(200);
      done();
    });
  });

  it('注册用户：POST /user 应当返回200',function(done){
    var postData = require('./zhangsan.json');
    client.post('/user', postData, function(err, req, res, data){
      should.not.exist(err);
      res.statusCode.should.eql(200);
      done();
    });
  });

});   