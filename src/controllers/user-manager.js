/**
 * Created by Wang, Qing. All rights reserved.
 *
 *================ Registration JSON Example ==================
 *{ 
 * 	"User": {
 * 		"id": null,
 * 		"Name": "赵五",
 *		"Avatar": null,
 *    "CurrentPhone": "23456789",
 * 		"SN": [{
 * 			"SnName": "豆瓣",
 * 			"AccountName": "赵五豆",
 * 		}],
 * 	},
 * 	"Contacts":[
 *	 	{
 *	 		"id": null,
 *	 		"Name": "张大三",
 *			"Avatar": null,
 *	    "CurrentPhone": "34567890",
 *	 	},
 *	 	{
 *	 		"id": null,
 *	 		"Name": "张老三",
 *			"Avatar": null,
 *	    "CurrentPhone": "34567890",
 *	 	}
 * 	]
 *}
 *============== Registration JSON Example End================
 */

var async = require('async')
	, config = require('../../config/config')
	,	mysqlConnection = require('../servers-init').mysqlConnection
	, couch = require('../servers-init').couch;

mysqlConnection.connect();


function registerUser(registerData, done){
	// console.log(registerData);
	if(registerData.User.id) throw new Error("Can't registered a User already with an id");

	var user = registerData.User
		,	contacts = registerData.Contacts

	var phoneNumber = registerData.User.CurrentPhone;

	getOrCreateUserWithPhoneNumberInMySQL(phoneNumber, true, function(userId){ // userId is not id, but uid
		storeOrUpdateUserContactBookInCouchDB(userId, registerData, function(){
			async.forEach(contacts, function(contact, next){
					getOrCreateUserWithPhoneNumberInMySQL(contact.CurrentPhone, false, function(contactUserId){
						bindContactWithUser(userId, contactUserId, contact, function(){
							next();
						});
					});
			}, function(err){
					if(err) throw err;
					storeOrUpdateUserContactBookInCouchDB(userId, registerData, function(){
						var result = {"userId" : userId};
						done(result);
					});
			});
		});
	});
}

function getOrCreateUserWithPhoneNumberInMySQL(phoneNumber, isRegistered, done){
	var userId = null;
	debugger;
	mysqlConnection.query('SELECT p.number, u.uid, u.name FROM user u, phone p WHERE u.id = p.owner_id AND p.number = ?',
		[phoneNumber], function(err, rows, fields){
			if(!rows || rows.length == 0){ // user doesn't exist
				mysqlConnection.query('INSERT INTO user SET uid = ?, is_registered = ?, last_modified_time = ?',
					[getUUid(), isRegistered, new Date()], function(err, results){
						if(err) console.log(err);
						var id = results.insertId;
						mysqlConnection.query('INSERT INTO phone SET number = ?, owner_id = ?',
							[phoneNumber, id], function(err, results){
								if(err) console.log(err);
								mysqlConnection.query('SELECT uid FROM user WHERE id = ?', [id], function(err, rows){
									if(err) console.log(err);
									userId = rows[0].uid;
									done(userId);
								});
							});
					});
			}else{
				userId = rows[0].uid;
				done(userId);
			}
	});
}

function storeOrUpdateUserContactBookInCouchDB(userId, contactBook, done){
	contactBook.User.uid = userId;
	var docId = getContactDocId(userId);
	var url = '/' + config.couch.db + '/' + docId;
	couch.put(url, contactBook, function(err, req, res, data){
		if(err) console.log(err);
		done();
	});
}


function bindContactWithUser(ownerId, contactUserId, contact, done){
	console.log(arguments.callee.name + ' is NOT IMPLEMENTED');
	done();
}

function getUUid(){
	return (new Date()).getTime();
}

function getContactDocId(userId){
  return userId + '-contacts-book'; //TODO: 
}

exports.registerUser = registerUser;
exports.getContactDocId = getContactDocId;