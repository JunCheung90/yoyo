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

[db, client] = [null null]

register-user = !(register-data, callback) ->
	throw new Error("Can't register a user with exist id") if register-data.uid
	response = {}
	response.user = user <<< register-data

	for phone in user.phones
		update-exist-user exist-user, user, phone if exist-user = get-user-with-phone phone
	return response if user.uid # 和目前已有的user合并了。如果没有uid，说明以前用户的这个电话，现在是当前用户用了。因此，还是要新建用户。

	current = new Date!.to-string!
	user.uid = util.get-UUid!
	user.is-registered = true
	user.last-modified-date = current
	user.merge-status = 'NONE'
	user.merge-to = null
	user.merge-from = []

	user.is-person = is-person user
	user.avatars = [create-default-system-avatar user] if not user?.avatar?.length
	user.current-avatar = user.avatars[0]
	[phone.start-using-time = current for phone in user.phones]

	return resopnse if not user.is-person # 单位（非个人）用户注册完毕，没有联系人

	[im.api-key = get-im-api-key im for im in user.ims]
	[sn.api-key = get-sn-api-key sn for im in user.sns]
	user.contacts-seq = 0
	create-contacts user.contacts, user.uid, user.contacts-seq
	user.as-contact-of = []

	user.contacted-strangers = []
	user.contacted-by-strangers = []

	# find-interesting-info-from-call-log user.call-log, response
	# find-interesting-info-from-im-log user.im-log, response

	db.collection('users').insert user, (err, result)->
		should.not.exist err 
		console.log 'response: %j' response
		callback response



!function update-exist-user exist-user, user, user-phone
	if is-same-user exist-user, user
		merge-user exist-user, user
	else
		[phone.is-active = false for phone in exist-user.phones when phone.phone-number is user-phone.phone-number]

function is-same-user a, b
	#TODO: using rule engine
	return false

function create-default-system-avatar user		
	#TODO: 
	return "NOT IMPLEMENTED YET."

function get-im-api-key im
	#TODO: 
	return "NOT IMPLEMENTED YET."

function get-sn-api-key sn
	#TODO: 
	return "NOT IMPLEMENTED YET."

!function create-contacts contacts, uid, seq
	# 每次发现contact需要和已有contact merge的时候，都新建一个contact，然后将
	# 两个contacts都merge到这个新的contact。
	contacts-uids = []
	contacts-map = {}
	merged-contacts = []
	for contact, i in contacts
		uid = get-uid-of-contact contact # uid is null if the user of the contact doesn't exist yet.
		if uid in contacts-uids
			new-contact = merge-contact contact, contacts-map[uid]  
			contacts-map[uid] = new-contact
			merged-contacts.push new-contact
		else
			uid = create-user-from-contact(contact).uid if not uid
			contacts-uids.push uid
		contact.uid = uid
		contact.cid = create-cid uid, ++seq

		contacts = contacts ++ merged-contacts


'''
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
'''