'''
 Created by Wang, Qing. All rights reserved.

================ Registration JSON Example ==================
{ 
 	"User": {
 		"id": null,
 		"Name": "赵五",
		"Avatar": null,
    "CurrentPhone": "23456789",
 		"SN": [{
 			"SnName": "豆瓣",
 			"AccountName": "赵五豆",
 		}],
 	},
 	"Contacts":[
	 	{
	 		"id": null,
	 		"Name": "张大三",
			"Avatar": null,
	    "CurrentPhone": "34567890",
	 	},
	 	{
	 		"id": null,
	 		"Name": "张老三",
			"Avatar": null,
	    "CurrentPhone": "34567890",
	 	}
 	]
}
============== Registration JSON Example End=================
'''

require! [async, '../config/config', 
					'../servers-init'.mysql-connection,
					'../servers-init'.couch]

mysql-connection.connect!

register-user = !(register-data, callback) ->
	throw new Error("Can't register a user with exist id") if register-data.User.id
	[user, contacts, phone-number] = [register-data.User, register-data.Contacts, register-data.User.CurrentPhone]

	(user-id) <-! get-or-create-user-with-phone-number phone-number, true
	<-! store-or-update-user-contact-book user-id, register-data
	<-! create-and-bind-user-contacts contacts
	<-! store-or-update-user-contact-book user-id, register-data	
	callback {user-id: user-id}


!function create-and-bind-user-contacts contacts, callback
	(err) <-! async.for-each contacts, !(contact, next) ->
		(contact-user-id) <-! get-or-create-user-with-phone-number contact.CurrentPhone, false
		<-! bind-contact-with-user user-id, contact-user-id, contact
		next!
	throw new Error err if err
	callback!


SQL_SELECT_USER_BY_PHONE_NUMBER = 'SELECT p.number, u.uid, u.name FROM user u, phone p WHERE u.id = p.owner_id AND p.number = ?'
SQL_INSERT_NEW_USER = 'INSERT INTO user SET uid = ?, is_registered = ?, last_modified_time = ?'
SQL_INSERT_NEW_PHONE = 'INSERT INTO phone SET number = ?, owner_id = ?'
SQL_SELECT_USR_BY_ID = 'SELECT uid FROM user WHERE id = ?'

!function get-or-create-user-with-phone-number phone-number, is-registered, callback
	debugger;
	(err, rows, fields) <-! mysql-connection.query SQL_SELECT_USER_BY_PHONE_NUMBER, [phoneNumber]
	throw new Error err if err
	if rows?.length > 0
		user-id = rows.0.id
		callback user-id
	else
		user-id = get-UUid!
		(err, inserted-user) <-! mysql-connection.query SQL_INSERT_NEW_USER, [user-id, is-registered, new Date!]
		throw new Error err if err
		(err, inserted-phone) <-! mysql-connection.query SQL_INSERT_NEW_PHONE, [phone-number, inserted-user.insert-id]
		throw new Error err if err
		callback user-id


!function store-or-update-user-contact-book user-id, contact-book, callback
	contact-book.User.uid = user-id
	doc-id = get-contact-doc-id user-id
	url = "/#{config.couch.db}/#{doc-id}"
	(err, req, res, doc) <-! couch.get url
	doc.User = contact-book
	(err, req, res, new-doc-result) <-! couch.put url, doc
	console.log "Couch Error: %j" err if err
	callback!

!function bind-contact-with-user owner-id, contact-user-id, contact, callback
	console.log "#{&.callee.name} is NOT IMPLEMENTED YET!"
	callback!

function get-UUid
	new Date!.get-time!

function get-contact-doc-id user-id
	"#{user-id}-contacts-book" #TODO


(exports ? this) <<< {register-user, get-contact-doc-id}



