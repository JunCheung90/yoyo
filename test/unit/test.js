if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var should, async, User, initMongoClient, shutdownMongoClient, util, _, ref$, db, client, multipleTimes, repeatRate, can, createAndCheckUser, checkUserContacts, areContactsMergedCorrect, isMergedResultContact, createAndCheckUserWithMulitpleRepeatContacts, addMultipleRepeatContacts, generateRandomContact, generateRepeatContact, randomSelect, isDefined, showContacts, exteningString;
should = require('should');
async = require('async');
User = require('../../src/models/User');
initMongoClient = require('../../src/servers-init').initMongoClient;
shutdownMongoClient = require('../../src/servers-init').shutdownMongoClient;
util = require('../../src/util');
_ = require('underscore');
ref$ = [null, null], db = ref$[0], client = ref$[1];
multipleTimes = 10;
repeatRate = 1;
can = it;
describe('mongoDb版注册用户：简单合并联系人', function(){
  var allOriginalContacts, nonRepeatOriginalContacts;
  before(function(done){
    initMongoClient(function(mongoClient, mongoDb){
      var ref$;
      ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
      db.dropCollection('users', function(){
        done();
      });
    });
  });
  allOriginalContacts = 3;
  nonRepeatOriginalContacts = 2;
  can('创建User赵五。赵五的联系人两个Contacts（张大三、张老三）合并为一。\n', function(done){
    createAndCheckUser('zhaowu.json', '赵五', function(){
      db.users.find({
        'name': '赵五'
      }).toArray(function(err, foundUsers){
        foundUsers.length.should.eql(1);
        areContactsMergedCorrect(foundUsers[0].contacts, nonRepeatOriginalContacts, function(){
          db.users.find().toArray(function(err, allUsers){
            allUsers.length.should.eql(3);
            done();
          });
        });
      });
    });
  });
  can('对多个重复联系人正确合并。\n', function(done){
    db.dropCollection('users', function(){
      createAndCheckUserWithMulitpleRepeatContacts('zhaowu.json', '赵五', function(nonRepeatContactsAmount){
        db.users.find({
          'name': '赵五'
        }).toArray(function(err, foundUsers){
          foundUsers.length.should.eql(1);
          foundUsers[0].contacts.length.should.eql(allOriginalContacts + multipleTimes);
          areContactsMergedCorrect(foundUsers[0].contacts, nonRepeatOriginalContacts + nonRepeatContactsAmount, function(){
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
  showContacts(contacts);
  mergedResultContacts = filter(isMergedResultContact, contacts);
  showContacts(mergedResultContacts);
  mergedResultContacts.length.should.eql(nonRepeatContactsAmount);
  callback();
};
isMergedResultContact = function(contact){
  return !contact.mergedTo;
};
createAndCheckUserWithMulitpleRepeatContacts = function(jsonFileName, userName, callback){
  var userData, nonRepeatContactsAmount;
  userData = util.loadJson(__dirname + ("/../test-data/" + jsonFileName));
  nonRepeatContactsAmount = addMultipleRepeatContacts(userData, multipleTimes, repeatRate);
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
addMultipleRepeatContacts = function(userData, multipleTimes, repeatRate){
  var seedContacts, nonRepeatContactsAmount, i$, ref$, len$, i, newContact;
  seedContacts = JSON.parse(JSON.stringify(userData.contacts));
  nonRepeatContactsAmount = 0;
  for (i$ = 0, len$ = (ref$ = (fn$())).length; i$ < len$; ++i$) {
    i = ref$[i$];
    if (repeatRate <= Math.random()) {
      newContact = generateRandomContact();
      nonRepeatContactsAmount++;
    } else {
      newContact = generateRepeatContact(seedContacts);
    }
    userData.contacts.push(newContact);
  }
  console.log("\n\n*************** " + nonRepeatContactsAmount + " ***************\n\n");
  return nonRepeatContactsAmount;
  function fn$(){
    var i$, to$, results$ = [];
    for (i$ = 1, to$ = multipleTimes; i$ <= to$; ++i$) {
      results$.push(i$);
    }
    return results$;
  }
};
generateRandomContact = function(){
  return {
    "names": [util.getUUid()]
  };
};
generateRepeatContact = function(seedContacts){
  var keys, contact, seed, differentValueKey, repeatValueKey;
  keys = ['ims'];
  contact = {};
  seed = randomSelect(seedContacts);
  differentValueKey = randomSelect(keys);
  contact[differentValueKey] = [Math.random() * 100000 + ''];
  repeatValueKey = randomSelect(filter(isDefined(seed), keys));
  contact[repeatValueKey] = seed[repeatValueKey];
  contact.names || (contact.names = ["repeat-contact-on-" + repeatValueKey]);
  return contact;
};
randomSelect = function(elements){
  if (!elements) {
    throw new Error("Can't' random select form " + elements);
  }
  return elements[Math.floor(Math.random() * elements.length)];
};
isDefined = curry$(function(obj, key){
  return _.isArray(obj[key]) && obj[key].length > 0;
});
showContacts = function(contacts){
  var i$, len$, contact, lresult$, phone, ref$, im, mTo, mFrom, f, results$ = [];
  if (!contacts) {
    return;
  }
  exteningString();
  console.log("\n\nid \t name \t\t phone \t\t im \t\t m-to \t\t m-from\n");
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    lresult$ = [];
    phone = contact != null && ((ref$ = contact.phones) != null && ref$.length) ? contact.phones[0] : '';
    im = contact != null && ((ref$ = contact.ims) != null && ref$.length) ? (ref$ = contact.ims[0]) != null ? ref$.account : void 8 : '';
    mTo = contact != null && contact.mergedTo ? contact.mergedTo.lastSubstring(5) : '';
    mFrom = contact != null && ((ref$ = contact.mergedFrom) != null && ref$.length) ? (fn$()) : '';
    lresult$.push(console.log(contact.cid.lastSubstring(5) + " \t " + contact.names[0].lastSubstring(5) + " \t " + phone + " \t " + im + " \t\t " + mTo + " \t" + mFrom));
    results$.push(lresult$);
  }
  return results$;
  function fn$(){
    var i$, ref$, len$, results$ = [];
    for (i$ = 0, len$ = (ref$ = contact.mergedFrom).length; i$ < len$; ++i$) {
      f = ref$[i$];
      results$.push(f.lastSubstring(5));
    }
    return results$;
  }
};
exteningString = function(){
  String.prototype.lastSubstring = function(position){
    return this.substring(this.length - position, this.length);
  };
};
function curry$(f, bound){
  var context,
  _curry = function(args) {
    return f.length > 1 ? function(){
      var params = args ? args.concat() : [];
      context = bound ? context || this : this;
      return params.push.apply(params, arguments) <
          f.length && arguments.length ?
        _curry.call(context, params) : f.apply(context, params);
    } : f;
  };
  return _curry();
}