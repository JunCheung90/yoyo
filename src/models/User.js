var async, util, createUserWithContacts, buildUserBasicInfo, createDefaultSystemAvatar, mergeSameUsers, newUserWithContacts, isPerson, createContacts, createContactsUsers, createCid, asyncGetApiKeys, asyncGetImApiKey, asyncGetSnApiKey;
async = require('async');
util = require('../util');
createUserWithContacts = function(db, userData, callback){
  var user;
  user = import$({}, userData);
  buildUserBasicInfo(user);
  debugger;
  mergeSameUsers(db, user, function(isMerged){
    if (!isMerged) {
      newUserWithContacts(db, user, function(){
        callback(user);
      });
    } else {
      callback(user);
    }
  });
};
buildUserBasicInfo = function(user){
  var current, ref$, i$, len$, phone;
  current = new Date().getTime();
  user.uid = util.getUUid();
  user.isRegistered = true;
  user.lastModifiedDate = current;
  user.mergeStatus = 'NONE';
  user.mergeTo = null;
  user.mergeFrom = [];
  if (!(user != null && ((ref$ = user.avatar) != null && ref$.length))) {
    user.avatars = [createDefaultSystemAvatar(user)];
  }
  user.currentAvatar = user.avatars[0];
  for (i$ = 0, len$ = (ref$ = user.phones).length; i$ < len$; ++i$) {
    phone = ref$[i$];
    phone.startUsingTime = current;
  }
};
createDefaultSystemAvatar = function(user){
  return console.log("create-default-system-avatar NOT IMPLEMENTED!");
};
mergeSameUsers = function(db, user, callback){
  console.log("merge-same-users NOT IMPLEMENTED!");
  callback(false);
};
newUserWithContacts = function(db, user, callback){
  user.asContactOf = [];
  user.contactedStrangers = [];
  user.contactedByStrangers = [];
  if (user.isPerson = isPerson(user)) {
    createContacts(db, user, function(){
      db.users.insert(user, function(err, result){
        if (err) {
          throw new Error(err);
        }
        asyncGetApiKeys(db, user);
        callback(user);
      });
    });
  } else {
    db.users.insert(user, function(err, result){
      if (err) {
        throw new Error(err);
      }
      callback(user);
    });
  }
};
isPerson = function(user){
  return true;
};
createContacts = function(db, user, callback){
  var toCreateContactUsers;
  user.contactsSeq = 0;
  toCreateContactUsers = [];
  async.forEach(user.contacts, function(contact, next){
    contact.cid = createCid(user.uid, ++user.contactsSeq);
    db.users.find({
      phones: {
        $all: contact.phones
      }
    }).toArray(function(err, contactUser){
      if ((contactUser != null ? contactUser.length : void 8) > 1) {
        throw new Error(contact + " refers to more than one user: " + contactUser);
      }
      if (!(contactUser != null && contactUser.length)) {
        toCreateContactUsers.push(contact);
      }
      next();
    });
  }, function(err){
    createContactsUsers(db, toCreateContactUsers, function(){
      callback();
    });
  });
};
createContactsUsers = function(db, contacts, callback){
  var users, i$, len$, contact, user, phones, emails, ims, sns;
  users = [];
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    user = (phones = contact.phones, emails = contact.emails, ims = contact.ims, sns = contact.sns, contact);
    contact.uid = user.uid = util.getUUid();
    user.isRegistered = false;
    users.push(user);
  }
  db.users.insert(users, function(err, users){
    if (err) {
      throw new Error(err);
    }
    callback();
  });
};
createCid = function(uid, seqNo){
  return uid + '-c-' + new Date().getTime() + '-' + seqNo;
};
asyncGetApiKeys = function(db, user){
  async.forEach(user.ims, function(im, next){
    asyncGetImApiKey(im, function(apiKey){
      im.apiKey = apiKey;
      next();
    });
  }, function(err){
    if (err) {
      throw new Error(err);
    }
    async.forEach(user.sns, function(sn, next){
      asyncGetSnApiKey(sn, function(apiKey){
        sn.apiKey = apiKey;
        next();
      });
    }, function(err){
      if (err) {
        throw new Error(err);
      }
      db.users.save(user, function(err, user){
        if (err) {
          throw new Error(err);
        }
      });
    });
  });
};
asyncGetImApiKey = function(im, callback){
  callback();
};
asyncGetSnApiKey = function(sn, callback){
  callback();
};
(typeof exports != 'undefined' && exports !== null ? exports : this).createUserWithContacts = createUserWithContacts;
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}