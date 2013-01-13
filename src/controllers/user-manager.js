' Created by Wang, Qing. All rights reserved.\n\n================ Registration JSON Example ==================\n{ \n 	"User": {\n 		"id": null,\n 		"Name": "赵五",\n		"Avatar": null,\n    "CurrentPhone": "23456789",\n 		"SN": [{\n 			"SnName": "豆瓣",\n 			"AccountName": "赵五豆",\n 		}],\n 	},\n 	"Contacts":[\n	 	{\n	 		"id": null,\n	 		"Name": "张大三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	},\n	 	{\n	 		"id": null,\n	 		"Name": "张老三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	}\n 	]\n}\n============== Registration JSON Example End=================';
var async, config, util, orm, User, Phone, Contact, couch, registerUser, ref$;
async = require('async');
config = require('../config/config');
util = require('../util');
orm = require('../servers-init').orm;
User = require('../models/user').User;
Phone = require('../models/phone').Phone;
Contact = require('../models/contact').Contact;
couch = require('../servers-init').couch;
registerUser = function(registerData, callback){
  var phoneData, userData;
  if (registerData.User.id) {
    throw new Error("Can't register a user with exist id");
  }
  phoneData = {
    number: registerData.User.CurrentPhone,
    isActive: true
  };
  userData = {
    uid: util.getUUid(),
    name: registerData.User.Name,
    isRegistered: true,
    isMerged: false
  };
  User.getOrCreateUserWithPhone(userData, phoneData, function(user){
    storeOrUpdateUserContactBook(user, registerData, function(){
      createAndBindUserContacts(user, registerData.Contacts, function(){
        storeOrUpdateUserContactBook(user, registerData, function(){
          callback({
            user: user
          });
        });
      });
    });
  });
};
function createAndBindUserContacts(user, contactsRegisterData, callback){
  async.forEach(contactsRegisterData, function(contactRegisterData, next){
    Contact.createAsUser(contactRegisterData, function(contact){
      user.bindHasContact(contact, function(){
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
function getContactDocId(userId){
  return userId + "-contacts-book";
}
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.registerUser = registerUser;
ref$.getContactDocId = getContactDocId;