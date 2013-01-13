var should, async, orm, User, Phone, Contact, dropCreateOrm, can;
should = require('should');
async = require('async');
orm = require('../../src/servers-init').orm;
User = require('../../src/models/user').User;
Phone = require('../../src/models/phone').Phone;
Contact = require('../../src/models/contact').Contact;
dropCreateOrm = require('../../src/orm-sync').dropCreateOrm;
can = it;
describe('Sequelize 用法', function(){
  before(function(done){
    dropCreateOrm(function(){
      done();
    });
  });
  can('创建User张三', function(done){
    var zhangsanData;
    zhangsanData = require('../test-data/zhangsan.json');
    User.getOrCreateUserWithRegisterData(zhangsanData, function(user){
      User.find({
        where: {
          name: '张三'
        }
      }).success(function(foundUser){
        foundUser.name.should.eql(user.name);
        console.log("\n\t成功创建了User：" + user.name);
        done();
      });
    });
  });
  can('添加张三Contact', function(done){
    var zhangsanContactsData;
    zhangsanContactsData = require('../test-data/zhangsan.json').Contacts;
    User.find({
      where: {
        name: '张三'
      }
    }).success(function(user){
      user.createAndBindContacts(zhangsanContactsData, function(){
        User.find({
          where: {
            name: '张三'
          }
        }).success(function(foundUser){
          foundUser.getHasContacts().success(function(contacts){
            console.log("\n\t找回的User：" + user.name + "有" + contacts.length + "个联系人：");
            contacts.length.should.eql(2);
            async.forEach(contacts, function(contact, next){
              console.log("\t" + contact.name);
              next();
            }, function(err){
              if (err) {
                throw new Error(err);
              }
              done();
            });
          });
        });
      });
    });
  });
  can('创建User李四', function(done){
    var lisiData;
    lisiData = require('../test-data/lisi.json');
    User.getOrCreateUserWithRegisterData(lisiData, function(user){
      User.find({
        where: {
          name: '李四'
        }
      }).success(function(foundUser){
        foundUser.name.should.eql(user.name);
        console.log("\n\t成功创建了User：" + user.name);
        done();
      });
    });
  });
  can('添加李四Contact', function(done){
    var lisiContactsData;
    lisiContactsData = require('../test-data/lisi.json').Contacts;
    User.find({
      where: {
        name: '李四'
      }
    }).success(function(user){
      user.createAndBindContacts(lisiContactsData, function(){
        User.find({
          where: {
            name: '李四'
          }
        }).success(function(foundUser){
          foundUser.getHasContacts().success(function(contacts){
            console.log("\n\t找回的User：" + user.name + "有" + contacts.length + "个联系人：");
            contacts.length.should.eql(2);
            async.forEach(contacts, function(contact, next){
              console.log("\t" + contact.name);
              next();
            }, function(err){
              if (err) {
                throw new Error(err);
              }
              foundUser.getAsContacts().success(function(contacts){
                console.log("\n\t找回的User：" + user.name + "充当" + contacts.length + "个联系人：");
                contacts.length.should.eql(1);
                async.forEach(contacts, function(contact, next){
                  console.log("\t" + contact.name);
                  next();
                }, function(err){
                  if (err) {
                    throw new Error(err);
                  }
                  done();
                });
              });
            });
          });
        });
      });
    });
  });
});