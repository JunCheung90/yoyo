var should, async, User, initMongoClient, shutdownMongoClient, ref$, db, client, multipleTimes, can;
should = require('should');
async = require('async');
User = require('../../src/models/User');
initMongoClient = require('../../src/servers-init').initMongoClient;
shutdownMongoClient = require('../../src/servers-init').shutdownMongoClient;
ref$ = [null, null], db = ref$[0], client = ref$[1];
multipleTimes = 1000;
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
  can('创建User张三，张三有2个Contacts，作为0人的Contact。\n', function(done){
    createAndCheckUser('zhangsan.json', '张三', function(){
      checkUserContacts('张三', multipleTimes + 2, 0, done);
    });
  });
  can('创建User李四，李四有2个Contacts，作为1人的Contact。\n', function(done){
    createAndCheckUser('lisi.json', '李四', function(){
      checkUserContacts('李四', multipleTimes + 2, 1, done);
    });
  });
  can('创建User赵五，赵五有3个Contacts，作为2人的Contacts。\n', function(done){
    createAndCheckUser('zhaowu.json', '赵五', function(){
      checkUserContacts('赵五', multipleTimes + 3, 2, done);
    });
  });
  can('最新张三联系人情况，有2个Contacts，作为2人的Contacts。\n', function(done){
    checkUserContacts('张三', multipleTimes + 2, 2, done);
  });
  after(function(done){
    shutdownMongoClient(client, function(){
      done();
    });
  });
});
function createAndCheckUser(jsonFileName, userName, callback){
  var userData;
  userData = require("../test-data/" + jsonFileName);
  userData = multipleContactsData(userData, multipleTimes);
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
}
function multipleContactsData(userData, contactsAmount){
  var i$, i;
  for (i$ = 1; i$ <= contactsAmount; ++i$) {
    i = i$;
    userData.contacts.push(generateFakeContact());
  }
  return userData;
}
function generateFakeContact(){
  var fakeContact;
  return fakeContact = {
    "phones": [Math.random() * 100000]
  };
}
function checkUserContacts(userName, amountOfHasContacts, amountOfAsContacts, callback){
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
}