var should, async, can;
should = require('should');
async = require('async');
can = it;
describe('Sequelize 用法', function(){
  can('创建User张三', function(done){
    checkCreateUserWith('zhangsan.json', '张三', done);
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