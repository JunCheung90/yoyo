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
					'../servers-init'.orm, 
					'../models/user'.User,
					'../models/phone'.Phone,
					'../models/contact'.Contact,
					'../servers-init'.couch]

register-user = !(register-data, callback) ->
	throw new Error("Can't register a user with exist id") if register-data.User.id
	[user-data, contacts-data, phone-number] = [register-data.User, register-data.Contacts, register-data.User.CurrentPhone]

	(user) <-! get-or-create-user-with-phone-number phone-number, user-data, true
	<-! store-or-update-user-contact-book user, register-data
	<-! create-and-bind-user-contacts user, contacts-data
	<-! store-or-update-user-contact-book user, register-data	
	callback {user: user}

!function create-and-bind-user-contacts user, contacts-data, callback
	(err) <-! async.for-each contacts-data, !(contact-data, next) ->
		(contact) <-! create-contact-as-user contact-data
		# (contact) <-! get-or-create-user-with-phone-number contact.CurrentPhone, {name:null}, false
		<-! bind-user-has-contact user, contact
		next!
	throw new Error err if err
	callback!

!function create-contact-as-user contact-data, callback
	# 如果找不到Contact对应的User，则需要新建一个无名的User。
	# TODO：注意：此时User并不应该设置Phone，Contact才应当设置。现在是直接将Phone建立在了User上，需要改进。
	(user) <-! get-or-create-user-with-phone-number contact-data.CurrentPhone, {name:null}, false
	(contact) <-! bind-user-as-contact user, contact-data
	user.save!.success !->
		contact.save!.success !->
			callback contact

!function bind-user-as-contact user, contact-data, callback
	Contact.create get-contact-register-data(contact-data) .success !(contact) ->
		debugger;
		user.add-as-contact contact .success !->
			contact.set-act-by user .success !->
				callback contact

function get-contact-register-data contact-data
	cid: get-UUid!
	name: contact-data.Name
	is-merged: false

!function bind-user-has-contact user, contact, callback
	user.add-has-contact contact .success !->
		contact.set-own-by user .success !->
			user.save!.success !->
				contact.save!.success !->
					callback!

!function get-or-create-user-with-phone-number phone-number, user-data, is-registered, callback
	Phone.find {where: {number: phone-number}} .success !(phone) ->
		if phone
			phone.get-own-by! .success !(owner) ->
				# TODO: check user against owner
				callback owner
		else
			create-user-with-phone get-user-register-data(user-data, is-registered), get-phone-register-data(phone-number), callback
	.error !(err) ->
		throw new Erro err if err

function get-user-register-data user, is-registered
	uid: get-UUid!
	name: user.Name
	is-registered: is-registered
	is-merged: false

function get-phone-register-data phone-number
	number: phone-number
	is-active: true


!function create-user-with-phone user-data, phone-data, callback
	Phone.create phone-data .success !(phone) ->
		User.create user-data .success !(user) ->
			user.addPhone phone .success !->
				user.save!.success !->
					callback user
				.error !(err) ->
					throw new Error err if err

!function store-or-update-user-contact-book user, contact-book, callback
	contact-book.User.uid = user.uid
	doc-id = get-contact-doc-id user.uid
	url = "/#{config.couch.db}/#{doc-id}"
	(err, req, res, doc) <-! couch.get url
	doc.User = contact-book
	(err, req, res, new-doc-result) <-! couch.put url, doc
	console.log "Couch Error: %j" err if err
	callback!

function get-UUid
	new Date!.get-time!

function get-contact-doc-id user-id
	"#{user-id}-contacts-book" #TODO


(exports ? this) <<< {register-user, get-contact-doc-id}



