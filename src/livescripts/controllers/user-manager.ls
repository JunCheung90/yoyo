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

require! ['../config/config',
					'../util', 
					'../servers-init'.orm, 
					'../models/user'.User,
					'../models/phone'.Phone,
					'../models/contact'.Contact,
					'../servers-init'.couch]

register-user = !(register-data, callback) ->
	throw new Error("Can't register a user with exist id") if register-data.User.id

	(user) <-! User.get-or-create-user-with-register-data register-data
	<-! store-or-update-user-contact-book user, register-data
	<-! user.create-and-bind-contacts register-data.Contacts
	<-! store-or-update-user-contact-book user, register-data	
	callback {user: user}

# TODO: 
# ====== The two functions below may be moved to a User Contact Book Manager in future =========
!function store-or-update-user-contact-book user, contact-book, callback
	contact-book.User.uid = user.uid
	doc-id = get-contact-doc-id user.uid
	url = "/#{config.couch.db}/#{doc-id}"
	(err, req, res, doc) <-! couch.get url
	doc.User = contact-book
	(err, req, res, new-doc-result) <-! couch.put url, doc
	console.log "Couch Error: %j" err if err
	callback!

function get-contact-doc-id user-id
	"#{user-id}-contacts-book" #TODO


(exports ? this) <<< {register-user, get-contact-doc-id}



