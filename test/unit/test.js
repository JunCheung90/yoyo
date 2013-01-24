var should, async, User, initMongoClient, shutdownMongoClient, ref$, db, client, can;
should = require('should');
async = require('async');
User = require('../../src/models/User');
initMongoClient = require('../../src/servers-init').initMongoClient;
shutdownMongoClient = require('../../src/servers-init').shutdownMongoClient;
ref$ = [null, null], db = ref$[0], client = ref$[1];
can = it;
describe('mongoDb版的注册用户', function(){
  before(function(done){
    initMongoClient(function(mongoClient, mongoDb){
      var ref$;
      ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
      db.dropCollection('users', function(){
        done();
      });
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
  User.createUserWithContacts(db, userData, function(user){
    db.users.find({
      name: '张三'
    }).toArray(function(err, foundUsers){
      foundUsers.length.should.eql(1);
      foundUsers[0].name.should.eql(user.name);
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