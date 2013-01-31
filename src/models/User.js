if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var async, util, Contact, createUserWithContacts, buildUserBasicInfo, createDefaultSystemAvatar, mergeSameUsers, createOrUpdateUserWithContacts, isPerson, asyncGetApiKeys, asyncGetImApiKey, asyncGetSnApiKey;
async = require('async');
util = require('../util');
Contact = require('./Contact');
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
  user.isMergePending = false;
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
      throw new Error(userAmount + " exist users are similar with " + user.name + ", THE LOGIC IS NOT IMPLEMENTED YET!");
    }
  });
};
createOrUpdateUserWithContacts = function(db, user, callback){
  user.asContactOf || (user.asContactOf = []);
  user.contactedStrangers || (user.contactedStrangers = []);
  user.contactedByStrangers || (user.contactedByStrangers = []);
  if (user.isPerson || (user.isPerson = isPerson(user))) {
    Contact.createContacts(db, user, function(){
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