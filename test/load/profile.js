if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
var should, async, User, initMongoClient, shutdownMongoClient, util, ref$, db, client, MULTIPLETIMES;
should = require('should');
async = require('async');
User = require('../../src/models/User');
initMongoClient = require('../../src/servers-init').initMongoClient;
shutdownMongoClient = require('../../src/servers-init').shutdownMongoClient;
util = require('../../src/util');
ref$ = [null, null], db = ref$[0], client = ref$[1];
MULTIPLETIMES = 1000;
initMongoClient(function(mongoClient, mongoDb){
  var ref$;
  ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
  db.dropCollection('users', function(){
    createAndCheckUser('zhangsan.json', '张三', MULTIPLETIMES, function(){
      createAndCheckUser('lisi.json', '李四', MULTIPLETIMES, function(){
        createAndCheckUser('zhaowu.json', '赵五', MULTIPLETIMES, function(){
          shutdownMongoClient(client, function(){});
        });
      });
    });
  });
});
function createAndCheckUser(jsonFileName, userName, fakeContactsAmount, callback){
  var userData, startTime;
  userData = util.loadJson(__dirname + ("/../test-data/" + jsonFileName));
  userData = multipleContactsData(userData, fakeContactsAmount);
  console.log("\n\n*************** " + userName + " has " + userData.contacts.length + " contacts. ************************\n\n");
  startTime = new Date();
  User.createUserWithContacts(db, userData, function(user){
    db.users.find({
      name: userName
    }).toArray(function(err, foundUsers){
      var endTime;
      foundUsers.length.should.eql(1);
      foundUsers[0].name.should.eql(userName);
      endTime = new Date();
      console.log("\n\t 耗费时间 " + (endTime - startTime));
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