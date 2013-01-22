' Created by Wang, Qing. All rights reserved.\n\n================ Registration JSON Example ==================\n{ \n 	"User": {\n 		"id": null,\n 		"Name": "赵五",\n		"Avatar": null,\n    "CurrentPhone": "23456789",\n 		"SN": [{\n 			"SnName": "豆瓣",\n 			"AccountName": "赵五豆",\n 		}],\n 	},\n 	"Contacts":[\n	 	{\n	 		"id": null,\n	 		"Name": "张大三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	},\n	 	{\n	 		"id": null,\n	 		"Name": "张老三",\n			"Avatar": null,\n	    "CurrentPhone": "34567890",\n	 	}\n 	]\n}\n============== Registration JSON Example End=================';
var mongo, util, initMongoClient, shutdownMongoClient, registerUser;
mongo = require('../config/config').mongo;
util = require('../util');
initMongoClient = require('../servers-init').initMongoClient;
shutdownMongoClient = require('../servers-init').shutdownMongoClient;
registerUser = function(registerData, callback){
  if (registerData.user.id) {
    throw new Error("Can't register a user with exist id");
  }
  getOrCreateUserWithRegisterData(registerData, function(user){
    createAndBindContacts(registerData.Contacts, function(){
      callback({
        user: user
      });
    });
  });
};
function getOrCreateUserWithRegisterData(registerData, callback){
  import$(userData, registerData);
  delete userData.contact;
  userData.uid = util.getUUid();
  initMongoClient(function(client, db){
    db.collection('users').update({
      a: 1
    }, {
      b: 1
    }, {
      upsert: true
    }, function(err, result){
      if (err) {
        throw new Error(err);
      }
      shutdownMongoClient(client);
      return callback(result);
    });
  });
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}