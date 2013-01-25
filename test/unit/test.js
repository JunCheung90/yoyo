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
  can('创建User张三，张三有2个Contacts，作为别人的0个Contact。', function(done){
    checkCreateUserWith('zhangsan.json', '张三', function(){
      checkUserContacts('张三', 2, 0, done);
    });
  });
  can('创建User李四，李四有2个Contacts，作为别人的1个Contact。', function(done){
    checkCreateUserWith('lisi.json', '李四', function(){
      checkUserContacts('李四', 2, 1, done);
    });
  });
  can('创建User赵五，赵五有3个Contacts，作为别人的2个Contacts。', function(done){
    checkCreateUserWith('zhaowu.json', '赵五', function(){
      checkUserContacts('赵五', 3, 2, done);
    });
  });
  can('最新张三联系人情况，有2个Contacts，作为别人的3个Contacts', function(done){
    checkUserContacts('张三', 2, 3, done);
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
function checkUserContacts(userName, amountOfHasContacts, amountOfAsContacts, callback){
  db.users.find({
    name: userName
  }).toArray(function(err, foundUsers){
    var foundUser, contact, name, sn;
    foundUsers.length.should.eql(1);
    foundUser = foundUsers[0];
    foundUser.contacts.length.should.eql(amountOfHasContacts);
    console.log("\n\t找回的User：" + userName + "有" + foundUser.contacts.length + "个联系人：%j", (function(){
      var i$, ref$, len$, lresult$, j$, ref1$, len1$, results$ = [];
      for (i$ = 0, len$ = (ref$ = foundUser.contacts).length; i$ < len$; ++i$) {
        contact = ref$[i$];
        lresult$ = [];
        for (j$ = 0, len1$ = (ref1$ = contact.names).length; j$ < len1$; ++j$) {
          name = ref1$[j$];
          lresult$.push(name);
        }
        results$.push(lresult$);
      }
      return results$;
    }()));
    foundUser.asContactOf.length.should.eql(amountOfAsContacts);
    console.log("\n\t找回的User：" + userName + "作为" + foundUser.asContactOf.length + "个联系人：%j", (function(){
      var i$, ref$, len$, lresult$, j$, ref1$, len1$, results$ = [];
      for (i$ = 0, len$ = (ref$ = foundUser.asContactOf).length; i$ < len$; ++i$) {
        contact = ref$[i$];
        lresult$ = [];
        for (j$ = 0, len1$ = (ref1$ = contact.names).length; j$ < len1$; ++j$) {
          name = ref1$[j$];
          lresult$.push(name);
        }
        results$.push(lresult$);
      }
      return results$;
    }()));
    console.log("\n\t找回的User：" + userName + "有" + foundUser.sns.length + "个SN：%j", (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = foundUser.sns).length; i$ < len$; ++i$) {
        sn = ref$[i$];
        results$.push({
          snName: sn.snName,
          accountName: sn.accountName
        });
      }
      return results$;
    }()));
    callback();
  });
}