var async, util, createUserWithContacts, buildUserBasicInfo, createDefaultSystemAvatar, mergeSameUsers, createOrUpdateUserWithContacts, isPerson, createContacts, identifyAndBindContactAsUser, bindContact, createContactsUsers, createCid, asyncGetApiKeys, asyncGetImApiKey, asyncGetSnApiKey;
async = require('async');
util = require('../util');
createUserWithContacts = function(db, userData, callback){
  var user;
  user = import$({}, userData);
  buildUserBasicInfo(user);
  mergeSameUsers(db, user, function(user){
    createOrUpdateUserWithContacts(db, user, function(){
      callback(user);
    });
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
createDefaultSystemAvatar = function(user){};
mergeSameUsers = function(db, user, callback){
  var phones, res$, i$, ref$, len$, phone, queryStatement;
  res$ = [];
  for (i$ = 0, len$ = (ref$ = user.phones).length; i$ < len$; ++i$) {
    phone = ref$[i$];
    res$.push(phone.phoneNumber);
  }
  phones = res$;
  queryStatement = {
    $or: [
      {
        "phones.phoneNumber": {
          $in: phones
        }
      }, {
        emails: {
          $in: user.emails || []
        }
      }
    ]
  };
  db.users.find(queryStatement).toArray(function(err, users){
    var existUser;
    if (err) {
      throw new Error(err);
    }
    switch (users.length) {
    case 0:
      callback(user);
      break;
    case 1:
      existUser = users[0];
      if (existUser.isRegistered) {
        throw new Error("User: " + user.name + " is conflict with exist user: " + existUser + ". THE HANDLER LOGIC IS NOT IMPLEMENTED YET!");
      }
      import$(existUser, user);
      db.users.save(existUser, function(err, result){
        if (err) {
          throw new Error(err);
        }
        callback(existUser);
      });
      break;
    default:
      if (userAmount > 1) {
        throw new Error(userAmount + " exist users are similar with " + user.name + ", THE LOGIC IS NOT IMPLEMENTED YET!");
      }
    }
  });
};
createOrUpdateUserWithContacts = function(db, user, callback){
  user.asContactOf || (user.asContactOf = []);
  user.contactedStrangers || (user.contactedStrangers = []);
  user.contactedByStrangers || (user.contactedByStrangers = []);
  if (user.isPerson || (user.isPerson = isPerson(user))) {
    createContacts(db, user, function(){
      db.users.save(user, function(err, result){
        if (err) {
          throw new Error(err);
        }
        asyncGetApiKeys(db, user);
        callback(user);
      });
    });
  } else {
    db.users.save(user, function(err, result){
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
  user.contactsSeq || (user.contactsSeq = 0);
  toCreateContactUsers = [];
  async.forEach(user.contacts, function(contact, next){
    (function(contact){
      contact.cid = createCid(user.uid, ++user.contactsSeq);
      identifyAndBindContactAsUser(db, contact, user, function(contactUserAmount){
        if (contactUserAmount > 1) {
          throw new Error(contact + " refers to more than one user: " + contactUser);
        }
        if (contactUserAmount === 0) {
          toCreateContactUsers.push(contact);
        }
        next();
      });
    })(contact);
  }, function(err){
    if (err) {
      throw new Error(err);
    }
    if (toCreateContactUsers.length > 0) {
      createContactsUsers(db, toCreateContactUsers, user, function(){
        callback();
      });
    } else {
      callback();
    }
  });
};
identifyAndBindContactAsUser = function(db, contact, owner, callback){
  var queryStatement;
  queryStatement = {
    $or: [
      {
        "phones.phoneNumber": {
          $in: contact.phones || []
        }
      }, {
        emails: {
          $in: contact.emails || []
        }
      }
    ]
  };
  db.users.find(queryStatement).toArray(function(err, contactUsers){
    var contactUserAmount;
    if (err) {
      throw new Error(err);
    }
    contactUserAmount = (contactUsers != null ? contactUsers.length : void 8) || 0;
    switch (contactUserAmount) {
    case 0:
      callback(0);
      break;
    case 1:
      bindContact(db, contact, contactUsers[0], owner, function(){
        callback(1);
      });
      break;
    default:
      callback(contactUserAmount);
    }
  });
};
bindContact = function(db, contact, contactUser, owner, callback){
  debugger;
  contact.uid = contactUser.uid;
  contactUser.asContactOf || (contactUser.asContactOf = []);
  contactUser.asContactOf.push(owner.uid);
  db.users.save(contactUser, function(err, result){
    if (err) {
      throw new Error(err);
    }
    callback();
  });
};
createContactsUsers = function(db, contacts, owner, callback){
  var users, i$, len$, contact, user;
  users = [];
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    user = {};
    user.phones = contact.phones, user.emails = contact.emails, user.ims = contact.ims, user.sns = contact.sns;
    contact.uid = user.uid = util.getUUid();
    user.isRegistered = false;
    user.asContactOf || (user.asContactOf = []);
    user.asContactOf.push(owner.uid);
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