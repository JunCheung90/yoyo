var should, orm, User, Phone, can;
should = require('should');
orm = require('../../output/servers-init').orm;
User = require('../../output/models/user').User;
Phone = require('../../output/models/phone').Phone;
can = it;
describe('Sequelize 用法', function(){
  var userData, phoneData;
  before(function(done){
    orm.sync({
      force: true
    }).success(function(){
      done();
    });
  });
  userData = {
    uid: '123',
    name: '张三',
    isRegistered: false,
    isMerged: false
  };
  phoneData = {
    number: 1234567,
    isActive: false
  };
  can('创建User', function(done){
    Phone.create(phoneData).success(function(phone){
      User.create(userData).success(function(user){
        user.addPhone(phone).success(function(){
          user.save().success(function(){
            console.log('成功创建了 %j', user);
            done();
          });
        });
      });
    });
  });
});