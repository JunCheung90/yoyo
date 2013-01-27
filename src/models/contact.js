var async, util, createContacts, identifyAndBindContactAsUser, bindContact, createContactsUsers, createCid;
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
createContactsUsers = function(db, contacts, owner, callback){
  var users, i$, len$, contact, user;
  users = [];
  for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
    contact = contacts[i$];
    user = {};
    user.phones = contact.phones, user.emails = contact.emails, user.ims = contact.ims, user.sns = contact.sns;
    contact.actByUser = user.uid = util.getUUid();
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