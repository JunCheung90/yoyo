' Created by Wang, Qing. All rights reserved.\n\n================ Registration JSON Example ==================\n{ \n 	"User": {\n 		"id": null,\n 		"Name": "赵五",\n		"Avatar": null,\n    "CurrentPhone": "23456789",\n 		"SN": [{\n 			"SnName": "豆瓣",\n 			"AccountName": "赵五豆",\n 		}],\n 	},\n 	"Contacts":[\n	 	{\n	 		"id": null,\n	 		"Name": "张大三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	},\n	 	{\n	 		"id": null,\n	 		"Name": "张老三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	}\n 	]\n}\n============== Registration JSON Example End=================';
var async, config, orm, User, Phone, Contact, couch, registerUser, ref$;
async = require('async');
config = require('../config/config');
orm = require('../servers-init').orm;
User = require('../models/user').User;
Phone = require('../models/phone').Phone;
Contact = require('../models/contact').Contact;
couch = require('../servers-init').couch;
registerUser = function(registerData, callback){
  var ref$, userData, contactsData, phoneNumber;
  if (registerData.User.id) {
    throw new Error("Can't register a user with exist id");
  }
  ref$ = [registerData.User, registerData.Contacts, registerData.User.CurrentPhone], userData = ref$[0], contactsData = ref$[1], phoneNumber = ref$[2];
  getOrCreateUserWithPhoneNumber(phoneNumber, userData, true, function(user){
    storeOrUpdateUserContactBook(user, registerData, function(){
      createAndBindUserContacts(user, contactsData, function(){
        storeOrUpdateUserContactBook(user, registerData, function(){
          callback({
            user: user
          });
        });
      });
    });
  });
};
function createAndBindUserContacts(user, contactsData, callback){
  async.forEach(contactsData, function(contactData, next){
    createContactAsUser(contactData, function(contact){
      bindUserHasContact(user, contact, function(){
        next();
      });
    });
  }, function(err){
    if (err) {
      throw new Error(err);
    }
    callback();
  });
}
function createContactAsUser(contactData, callback){
  getOrCreateUserWithPhoneNumber(contactData.CurrentPhone, {
    name: null
  }, false, function(user){
    bindUserAsContact(user, contactData, function(contact){
      user.save().success(function(){
        contact.save().success(function(){
          callback(contact);
        });
      });
    });
  });
}
function bindUserAsContact(user, contactData, callback){
  Contact.create(getContactRegisterData(contactData)).success(function(contact){
    debugger;
    user.addAsContact(contact).success(function(){
      contact.setActBy(user).success(function(){
        callback(contact);
      });
    });
  });
}
function getContactRegisterData(contactData){
  return {
    cid: getUUid(),
    name: contactData.Name,
    isMerged: false
  };
}
function bindUserHasContact(user, contact, callback){
  user.addHasContact(contact).success(function(){
    contact.setOwnBy(user).success(function(){
      user.save().success(function(){
        contact.save().success(function(){
          callback();
        });
      });
    });
  });
}
function getOrCreateUserWithPhoneNumber(phoneNumber, userData, isRegistered, callback){
  Phone.find({
    where: {
      number: phoneNumber
    }
  }).success(function(phone){
    if (phone) {
      phone.getOwnBy().success(function(owner){
        callback(owner);
      });
    } else {
      createUserWithPhone(getUserRegisterData(userData, isRegistered), getPhoneRegisterData(phoneNumber), callback);
    }
  }).error(function(err){
    if (err) {
      throw new Erro(err);
    }
  });
}
function getUserRegisterData(user, isRegistered){
  return {
    uid: getUUid(),
    name: user.Name,
    isRegistered: isRegistered,
    isMerged: false
  };
}
function getPhoneRegisterData(phoneNumber){
  return {
    number: phoneNumber,
    isActive: true
  };
}
function createUserWithPhone(userData, phoneData, callback){
  Phone.create(phoneData).success(function(phone){
    User.create(userData).success(function(user){
      user.addPhone(phone).success(function(){
        user.save().success(function(){
          callback(user);
        }).error(function(err){
          if (err) {
            throw new Error(err);
          }
        });
      });
    });
  });
}
function storeOrUpdateUserContactBook(user, contactBook, callback){
  var docId, url;
  contactBook.User.uid = user.uid;
  docId = getContactDocId(user.uid);
  url = "/" + config.couch.db + "/" + docId;
  couch.get(url, function(err, req, res, doc){
    doc.User = contactBook;
    couch.put(url, doc, function(err, req, res, newDocResult){
      if (err) {
        console.log("Couch Error: %j", err);
      }
      callback();
    });
  });
}
function getUUid(){
  return new Date().getTime();
}
function getContactDocId(userId){
  return userId + "-contacts-book";
}
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.registerUser = registerUser;
ref$.getContactDocId = getContactDocId;