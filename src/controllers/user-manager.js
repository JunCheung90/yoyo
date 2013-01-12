' Created by Wang, Qing. All rights reserved.\n\n================ Registration JSON Example ==================\n{ \n 	"User": {\n 		"id": null,\n 		"Name": "赵五",\n		"Avatar": null,\n    "CurrentPhone": "23456789",\n 		"SN": [{\n 			"SnName": "豆瓣",\n 			"AccountName": "赵五豆",\n 		}],\n 	},\n 	"Contacts":[\n	 	{\n	 		"id": null,\n	 		"Name": "张大三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	},\n	 	{\n	 		"id": null,\n	 		"Name": "张老三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	}\n 	]\n}\n============== Registration JSON Example End=================';
var async, config, mysqlConnection, couch, registerUser, SQL_SELECT_USER_BY_PHONE_NUMBER, SQL_INSERT_NEW_USER, SQL_INSERT_NEW_PHONE, SQL_SELECT_USR_BY_ID, ref$;
async = require('async');
config = require('../config/config');
mysqlConnection = require('../servers-init').mysqlConnection;
couch = require('../servers-init').couch;
mysqlConnection.connect();
registerUser = function(registerData, callback){
  var ref$, user, contacts, phoneNumber;
  if (registerData.User.id) {
    throw new Error("Can't register a user with exist id");
  }
  ref$ = [registerData.User, registerData.Contacts, registerData.User.CurrentPhone], user = ref$[0], contacts = ref$[1], phoneNumber = ref$[2];
  getOrCreateUserWithPhoneNumber(phoneNumber, true, function(userId){
    storeOrUpdateUserContackBook(userId, registerData, function(){
      async.forEach(contacts, function(contact, next){
        getOrCreateUserWithPhoneNumber(contact.CurrentPhone, false, function(contactUserId){
          bindContactWithUser(userId, contactUserId, contact, function(){
            next();
          });
        });
      }, function(err){
        if (err) {
          throw new Error(err);
        }
        storeOrUpdateUserContackBook(userId, registerData, function(){
          callback({
            userId: userId
          });
        });
      });
    });
  });
};
SQL_SELECT_USER_BY_PHONE_NUMBER = 'SELECT p.number, u.uid, u.name FROM user u, phone p WHERE u.id = p.owner_id AND p.number = ?';
SQL_INSERT_NEW_USER = 'INSERT INTO user SET uid = ?, is_registered = ?, last_modified_time = ?';
SQL_INSERT_NEW_PHONE = 'INSERT INTO phone SET number = ?, owner_id = ?';
SQL_SELECT_USR_BY_ID = 'SELECT uid FROM user WHERE id = ?';
function getOrCreateUserWithPhoneNumber(phoneNumber, isRegistered, callback){
  var userId;
  userId = null;
  debugger;
  mysqlConnection.query(SQL_SELECT_USER_BY_PHONE_NUMBER, [phoneNumber], function(err, rows, fields){
    var userId, u;
    if (err) {
      throw new Error(err);
    }
    if ((rows != null ? rows.length : void 8) > 0) {
      userId = rows[0].id;
      callback(userId);
    } else {
      u = getUUid();
      mysqlConnection.query(SQL_INSERT_NEW_USER, [uid, isRegistered, new Date()], function(err, insertedUser){
        if (err) {
          throw new Error(err);
        }
        mysqlConnection.query(SQL_INSERT_NEW_PHONE, [phoneNumber, insertedUser.insertId], function(err, insertedPhone){
          if (err) {
            throw new Error(err);
          }
          callback(uid);
        });
      });
    }
  });
}
function storeOrUpdateUserContackBook(userId, contactBook, callback){
  var docId, url;
  contactBook.User.uid = userId;
  docId = getContactDocId(userId);
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
function bindContactWithUser(ownerId, contactUserId, contact, callback){
  console.log(arguments.callee.name + " is NOT IMPLEMENTED YET!");
  callback();
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