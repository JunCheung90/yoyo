if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
var async, util, createContacts, identifyAndBindContactAsUser, bindContact, mergeContacts, createContactsUsers, createCid, mergeStrategy, _und, checkAndMergeContacts, shouldContactsBeMerged, mergeTwoContacts, selectMergeTo;
async = require('async');
util = require('../util');
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
    mergeContacts(user.contacts);
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
  contact.actByUser = contactUser.uid;
  contactUser.asContactOf || (contactUser.asContactOf = []);
  contactUser.asContactOf.push(owner.uid);
  db.users.save(contactUser, function(err, result){
    if (err) {
      throw new Error(err);
    }
    callback();
  });
};
mergeContacts = function(contacts){
  var contactsChecked, i$, len$, contact, uid;
  contactsChecked = [];
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    uid = util.getUUid();
    contact.actByUser = util.getUUid();
    checkAndMergeContacts(contact, contactsChecked);
    contactsChecked.push(contact);
  }
};
createContactsUsers = function(db, contacts, owner, callback){
  var users, i$, len$, contact, user;
  users = [];
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    if (contact.mergedTo) {
      continue;
    }
    user = {};
    user.phones = contact.phones, user.emails = contact.emails, user.ims = contact.ims, user.sns = contact.sns;
    user.uid = contact.actByUser;
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
(typeof exports != 'undefined' && exports !== null ? exports : this).createContacts = createContacts;
mergeStrategy = require('../contacts-merging-strategy');
_und = require('underscore');
checkAndMergeContacts = function(contactBeingChecked, contacts){
  var i$, len$, contact;
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    if (contact.mergedTo && !contact.isMergePending) {
      continue;
    }
    switch (shouldContactsBeMerged(contact, contactBeingChecked)) {
    case "NONE":
      continue;
    case "PENDING":
      contactBeingChecked.isMergePending = contact.isMergePending = true;
      break;
    case "MERGED":
      contactBeingChecked.isMergePending = contact.isMergePending = false;
    }
    mergeTwoContacts(contact, contactBeingChecked);
  }
};
shouldContactsBeMerged = function(c1, c2){
  var i$, ref$, len$, key;
  for (i$ = 0, len$ = (ref$ = mergeStrategy.directMerging).length; i$ < len$; ++i$) {
    key = ref$[i$];
    if (_und.isArray(c1[key])) {
      if (!_und.isEmpty(_und.intersection(c1[key], c2[key]))) {
        return "MERGED";
      }
    } else {
      if (_und.isEqual(c1[key], c2[key])) {
        return "MERGED";
      }
    }
  }
  for (i$ = 0, len$ = (ref$ = mergeStrategy.recommandMerging).length; i$ < len$; ++i$) {
    key = ref$[i$];
    if (_und.isArray(c1[key])) {
      if (!_und.isEmpty(_und.intersection(c1[key], c2[key]))) {
        return "PENDING";
      }
    } else {
      if (_und.isEqual(c1[key], c2[key])) {
        return "PENDING";
      }
    }
  }
  return "NONE";
};
mergeTwoContacts = function(c1, c2){
  var mTo, mFrom, i$, ref$, len$, key;
  mTo = selectMergeTo(c1, c2);
  mFrom = mTo.cid === c1.cid ? c2 : c1;
  debugger;
  mTo.mergedFrom || (mTo.mergedFrom = []);
  mTo.mergedFrom.push(mFrom.cid);
  mFrom.mergedTo = mTo.cid;
  mFrom.actByUser = mTo.actByUser;
  if (mTo.isMergePending) {
    return null;
  }
  for (i$ = 0, len$ = (ref$ = _und.keys(c1)).length; i$ < len$; ++i$) {
    key = ref$[i$];
    if (key == 'cid' || key == 'isMergePending' || key == 'mergedTo' || key == 'mergedFrom') {
      continue;
    }
    if (_und.isArray(c1[key])) {
      mTo[key] = _und.union(mTo[key], mFrom[key]);
    } else {
      if (mTo[key] !== mFrom[key]) {
        throw new Error(mTo.names + " and " + mFrom.names + " contact merging CONFLICT for key: " + key + ", with different value: " + mTo[key] + ", " + mFrom[key]);
      }
    }
  }
  return mTo;
};
selectMergeTo = function(c1, c2){
  return c1;
};