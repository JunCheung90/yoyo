if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
' Created by Wang, Qing. All rights reserved.\n\n================ Registration JSON Example ==================\n{ \n 	"User": {\n 		"id": null,\n 		"Name": "赵五",\n		"Avatar": null,\n    "CurrentPhone": "23456789",\n 		"SN": [{\n 			"SnName": "豆瓣",\n 			"AccountName": "赵五豆",\n 		}],\n 	},\n 	"Contacts":[\n	 	{\n	 		"id": null,\n	 		"Name": "张大三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	},\n	 	{\n	 		"id": null,\n	 		"Name": "张老三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	}\n 	]\n}\n============== Registration JSON Example End=================';
var mongo, util, initMongoClient, shutdownMongoClient, ref$, db, client;
mongo = require('../config/config').mongo;
util = require('../util');
initMongoClient = require('../servers-init').initMongoClient;
shutdownMongoClient = require('../servers-init').shutdownMongoClient;
ref$ = [null, null], db = ref$[0], client = ref$[1];
initMongoClient(function(mongoClient, mongoDb){
  var ref$, registerUser, createUserAndMiningInterestingInfo;
  ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
  registerUser = function(registerData, callback){
    var response;
    if (registerData.uid) {
      throw new Error("Can't register a user with exist id");
    }
    response = {};
    if (!db) {
      initMongoClient(function(mongoClient, mongoDb){
        var ref$;
        ref$ = [mongoDb, mongoClient], db = ref$[0], client = ref$[1];
        createUserAndMiningInterestingInfo(db, registerData, function(user, info){
          var ref$;
          ref$ = [user, info], response.user = ref$[0], response.interestingInfo = ref$[1];
          callback(response);
        });
      });
    } else {
      createUserAndMiningInterestingInfo(db, registerData, function(user, info){
        var ref$;
        ref$ = [user, info], response.user = ref$[0], response.interestingInfo = ref$[1];
        callback(response);
      });
    }
  };
  createUserAndMiningInterestingInfo = function(db, registerData, callback){
    User.createUserWithContacts(db, registerData.user, function(user){
      User.miningInterestingInfo(db, user, function(info){
        callback(user, info);
      });
    });
  };
  function updateExistUser(existUser, user, userPhone){
    var i$, ref$, len$, phone;
    if (isSameUser(existUser, user)) {
      mergeUser(existUser, user);
    } else {
      for (i$ = 0, len$ = (ref$ = existUser.phones).length; i$ < len$; ++i$) {
        phone = ref$[i$];
        if (phone.phoneNumber === userPhone.phoneNumber) {
          phone.isActive = false;
        }
      }
    }
  }
  function isSameUser(a, b){
    return false;
  }
  function createDefaultSystemAvatar(user){
    return "NOT IMPLEMENTED YET.";
  }
  function getImApiKey(im){
    return "NOT IMPLEMENTED YET.";
  }
  function getSnApiKey(sn){
    return "NOT IMPLEMENTED YET.";
  }
  function createContacts(contacts, uid, seq){
    var contactsUids, contactsMap, mergedContacts, i$, len$, i, contact, newContact;
    contactsUids = [];
    contactsMap = {};
    mergedContacts = [];
    for (i$ = 0, len$ = contacts.length; i$ < len$; ++i$) {
      i = i$;
      contact = contacts[i$];
      uid = getUidOfContact(contact);
      if (in$(uid, contactsUids)) {
        newContact = mergeContact(contact, contactsMap[uid]);
        contactsMap[uid] = newContact;
        mergedContacts.push(newContact);
      } else {
        if (!uid) {
          uid = createUserFromContact(contact).uid;
        }
        contactsUids.push(uid);
      }
      contact.uid = uid;
      contact.cid = createCid(uid, ++seq);
      contacts = contacts.concat(mergedContacts);
    }
  }
  '	(user) <-! get-or-create-user-with-register-data register-data\n	<-! create-and-bind-contacts register-data.Contacts\n	# TODO: -! store-or-update-user-contact-book user, register-data	\n	callback {user: user}\n\n!function get-or-create-user-with-register-data register-data, callback\n	user-data <<< register-data\n	delete user-data.contact\n	user-data.uid = util.get-UUid!\n	(client, db) <-! init-mongo-client\n	db.collection(\'users\').update {a:1}, {b:1}, {upsert:true}, (err, result)->\n		throw new Error err if err\n		shutdown-mongo-client client\n		callback result';
});
function in$(x, arr){
  var i = -1, l = arr.length >>> 0;
  while (++i < l) if (x === arr[i] && i in arr) return true;
  return false;
}