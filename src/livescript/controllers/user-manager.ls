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

require! ['../config/config'.mongo,
					'../util'
					'../servers-init'.init-mongo-client, 
					'../servers-init'.shutdown-mongo-client]


register-user = !(register-data, callback) ->
	throw new Error("Can't register a user with exist id") if register-data.user.id

	(user) <-! get-or-create-user-with-register-data register-data
	<-! create-and-bind-contacts register-data.Contacts
	# TODO: -! store-or-update-user-contact-book user, register-data	
	callback {user: user}

!function get-or-create-user-with-register-data register-data, callback
	user-data <<< register-data
	delete user-data.contact
	user-data.uid = util.get-UUid!
	(client, db) <-! init-mongo-client
	db.collection('users').update {a:1}, {b:1}, {upsert:true}, (err, result)->
		throw new Error err if err
		shutdown-mongo-client client
		callback result