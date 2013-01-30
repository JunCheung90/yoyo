if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var should, async, User, initMongoClient, shutdownMongoClient, util, ref$, db, client, multipleTimes, can, createAndCheckUser, checkUserContacts, areContactsMergedCorrect, isMergedResultContact, createAndCheckUserWithMulitpleRepeatContacts, addMultipleRepeatContacts;
should = require('should');
async = require('async');
User = require('../../src/models/User');
initMongoClient = require('../../src/servers-init').initMongoClient;
shutdownMongoClient = require('../../src/servers-init').shutdownMongoClient;
util = require('../../src/util');
ref$ = [null, null], db = ref$[0], client = ref$[1];
multipleTimes = 1000;
can = it;
describe('mongoDb版注册用户：识别用户，绑定用户（User）和联系人（Contact）', function(){
  before(function(done){
    initMongoClient(function(mongoClient, mongoDb){
      var ref$;
      ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
      db.dropCollection('users', function(){
        done();
      });
    });
  });
  can('创建User张三，张三有2个Contacts，作为0人的Contact。\n', function(done){
    createAndCheckUser('zhangsan.json', '张三', function(){
      checkUserContacts('张三', 2, 0, done);
    });
  });
  can('创建User李四，李四有2个Contacts，作为1人的Contact。\n', function(done){
    createAndCheckUser('lisi.json', '李四', function(){
      checkUserContacts('李四', 2, 1, done);
    });
  });
  can('创建User赵五，赵五有3个Contacts，作为2人的Contacts。\n', function(done){
    createAndCheckUser('zhaowu.json', '赵五', function(){
      checkUserContacts('赵五', 3, 2, done);
    });
  });
  can('最新张三联系人情况，有2个Contacts，作为2人的Contacts。\n', function(done){
    checkUserContacts('张三', 2, 2, done);
  });
  after(function(done){
    shutdownMongoClient(client, function(){
      done();
    });
  });
});
describe('mongoDb版注册用户：合并联系人', function(){
  before(function(done){
    initMongoClient(function(mongoClient, mongoDb){
      var ref$;
      ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
      db.dropCollection('users', function(){
        done();
      });
    });
  });
  can('创建User赵五。赵五的联系人两个Contacts（张大三、张老三）合并为一。\n', function(done){
    createAndCheckUser('zhaowu.json', '赵五', function(){
      db.users.find({
        'name': '赵五'
      }).toArray(function(err, foundUsers){
        foundUsers.length.should.eql(1);
        areContactsMergedCorrect(foundUsers[0].contacts, 1, function(){
          db.users.find().toArray(function(err, allUsers){
            allUsers.length.should.eql(3);
            done();
          });
        });
      });
    });
  });
  after(function(done){
    shutdownMongoClient(client, function(){
      done();
    });
  });
});
createAndCheckUser = function(jsonFileName, userName, callback){
  var userData;
  userData = util.loadJson(__dirname + ("/../test-data/" + jsonFileName));
  User.createUserWithContacts(db, userData, function(user){
    db.users.find({
      name: userName
    }).toArray(function(err, foundUsers){
      foundUsers.length.should.eql(1);
      foundUsers[0].name.should.eql(userName);
      console.log("\n\t成功创建了User：" + foundUsers[0].name);
      callback();
    });
  });
};
checkUserContacts = function(userName, amountOfHasContacts, amountOfAsContacts, callback){
  db.users.find({
    name: userName
  }).toArray(function(err, foundUsers){
    var foundUser, sn;
    foundUsers.length.should.eql(1);
    foundUser = foundUsers[0];
    foundUser.contacts.length.should.eql(amountOfHasContacts);
    foundUser.asContactOf.length.should.eql(amountOfAsContacts);
    console.log("\n\t找回的User：" + userName + "作为" + foundUser.asContactOf.length + "个联系人");
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
};
areContactsMergedCorrect = function(contacts, nonRepeatContactsAmount, callback){
  var mergedResultContacts;
  mergedResultContacts = filter(isMergedResultContact, contacts);
  mergedResultContacts.length.should.eql(nonRepeatContactsAmount);
  callback();
};
isMergedResultContact = function(contact){
  return contact.mergedFrom && !contact.mergeTo;
};
createAndCheckUserWithMulitpleRepeatContacts = function(jsonFileName, userName, callback){
  var userData, nonRepeatContactsAmount;
  userData = util.loadJson(__dirname + ("/../test-data/" + jsonFileName));
  nonRepeatContactsAmount = addMultipleRepeatContacts(userData, multipleTimes);
  return User.createUserWithContacts(db, userData, function(user){
    db.users.find({
      name: userName
    }).toArray(function(err, foundUsers){
      foundUsers.length.should.eql(1);
      foundUsers[0].name.should.eql(userName);
      console.log("\n\t成功创建了User：" + foundUsers[0].name);
      callback(nonRepeatContactsAmount);
    });
  });
};
addMultipleRepeatContacts = function(userData, multipleTimes){};