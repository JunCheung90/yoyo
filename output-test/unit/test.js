var should, orm, User, Phone;
should = require('should');
orm = require('../../output/servers-init').orm;
User = require('../../src/models/user').User;
Phone = require('../../src/models/phone').Phone;
desrcibe('Sequelize 用法', function(){
  before(function(done){
    var userData, phoneData;
    orm.sync();
    done();
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
    it('创建User', function(done){});
    Phone.create(phoneData).success(function(phone){
      User.create(userData).success(function(user){
        user.addPhone(phone).success(function(){
          done();
        }).error(function(err){
          should.not.exist(err);
          done();
        });
      }).error(function(err){
        should.not.exist(err);
        done();
      });
    });
  });
});