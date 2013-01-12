var should, async, orm, User, Phone, dropCreateOrm, can;
should = require('should');
async = require('async');
orm = require('../../src/servers-init').orm;
User = require('../../src/models/user').User;
Phone = require('../../src/models/phone').Phone;
dropCreateOrm = require('../../src/orm-sync').dropCreateOrm;
can = it;
describe('Sequelize 用法', function(){
  can('查找User', function(done){
    User.find({
      where: {
        name: '张三'
      }
    }).success(function(user){
      console.log('\n成功找到了User %j', user);
      user.getHasContacts().success(function(contacts){
        console.log("\n找到" + contacts.length + "个has联系人");
        async.forEach(contacts, function(contact, next){
          console.log("\n成功找到了User: " + user.name + "，的联系人：" + contact.name);
          next();
        }, function(err){
          user.getAsContacts().success(function(contacts){
            console.log("\n找到" + contacts.length + "个as联系人");
            async.forEach(contacts, function(contact, next){
              console.log("\n成功找到了User: " + user.name + "，act as的联系人：" + contact.name);
              next();
            }, function(err){
              done();
            });
          });
        });
      });
    }).error(function(err){
      console.log(err);
      done();
    });
  });
});