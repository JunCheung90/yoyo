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
    checkCreateUserWith('zhangsan.json', '张三', done);
  });
  can('添加张三Contacts后，张三有2个Contacts，作为别人的0个Contact', function(done){
    createUserContacts('zhangsan.json', '张三', function(){
      checkUserContacts('张三', 2, 0, done);
    });
  });
  can('创建User李四', function(done){
    checkCreateUserWith('lisi.json', '李四', done);
  });
  can('添加李四Contacts后，李四有2个Contacts，作为别人的1个Contact', function(done){
    createUserContacts('lisi.json', '李四', function(){
      checkUserContacts('李四', 2, 1, done);
    });
  });
  can('创建User赵五', function(done){
    checkCreateUserWith('zhaowu.json', '赵五', done);
  });
  can('添加赵五Contacts后，赵五有3个Contacts，作为别人的2个Contacts', function(done){
    createUserContacts('zhaowu.json', '赵五', function(){
      checkUserContacts('赵五', 3, 2, done);
    });
  });
  can('最新张三联系人情况，有2个Contacts，作为别人的3个Contacts', function(done){
    checkUserContacts('张三', 2, 3, done);
  });
});
function checkCreateUserWith(jsonFileName, userName, callback){
  var userData;
  userData = require("../test-data/" + jsonFileName);
  User.getOrCreateUserWithRegisterData(userData, function(user){
    User.find({
      where: {
        name: userName
      }
    }).success(function(foundUser){
      foundUser.name.should.eql(user.name);
      console.log("\n\t成功创建了User：" + user.name);
      callback();
    });
  });
}
function createUserContacts(jsonFileName, userName, callback){
  var contactsData;
  contactsData = require("../test-data/" + jsonFileName).Contacts;
  User.find({
    where: {
      name: userName
    }
  }).success(function(user){
    user.createAndBindContacts(contactsData, function(){
      callback();
    });
  });
}
function checkUserContacts(userName, amountOfHasContacts, amountOfAsContacts, callback){
  User.find({
    where: {
      name: userName
    }
  }).success(function(foundUser){
    foundUser.getHasContacts().success(function(contacts){
      console.log("\n\t找回的User：" + userName + "有" + contacts.length + "个联系人：");
      contacts.length.should.eql(amountOfHasContacts);
      async.forEach(contacts, function(contact, next){
        console.log("\t" + contact.name);
        next();
      }, function(err){
        if (err) {
          throw new Error(err);
        }
        foundUser.getAsContacts().success(function(contacts){
          console.log("\n\t找回的User：" + userName + "充当" + contacts.length + "个联系人：");
          contacts.length.should.eql(amountOfAsContacts);
          async.forEach(contacts, function(contact, next){
            console.log("\t" + contact.name);
            next();
          }, function(err){
            if (err) {
              throw new Error(err);
            }
            foundUser.getSocials().success(function(socials){
              console.log("\n\t找回的User：" + userName + "有" + socials.length + "个SN：");
              async.forEach(socials, function(social, next){
                console.log("\t" + social.account);
                next();
              }, function(err){
                callback();
              });
            });
          });
        });
      });
    });
  });
}