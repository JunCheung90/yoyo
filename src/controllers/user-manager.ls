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

require! ['../models/Users'
					'./call-log-manager']

User-manager = 
	register-user: !(register-data, callback) ->
		response = {}
		if !register-data.user?
			[response.result-code, response.error-message] = [2, "miss necessary argument: user"]
			return callback response

		if !register-data.user?.phones?
			[response.result-code, response.error-message] = [2, "miss necessary argument: user's phones"]
			return callback response

		if !register-data.user?.contacts?
			[response.result-code, response.error-message] = [2, "miss necessary argument: user's contacts"]
			return callback response

		if !register-data.call-logs?
			[response.result-code, response.error-message] = [2, "miss necessary argument: user's callLogs"]
			return callback response

		if register-data.user.uid
			[response.result-code, response.error-message] = [3, "Can't register a user with exist id"]
			return callback response
		# throw new Error("Can't register a user with exist id") if register-data.uid		
		(user, info) <-! create-user-and-mining-interesting-info register-data.user
		<-! call-log-manager.update-user-call-logs user, register-data.call-logs, register-data.last-call-log-time
		[response.result-code, response.user, response.interesting-info] = [0, user, info]
		callback response
		

	update-user: !(update-data, callback) ->
		response = {}
		if !update-data.uid?
			[response.result-code, response.error-message] = [2, "miss necessary argument: uid"]
			return callback response

		(user) <- Users.update-user-profile update-data
		[response.result-code, response.user] = [0, user]
		callback response

	update-user-sn-api-key: !(update-data, callback) ->
		(err) <-! Users.update-user-sn-api-key update-data.uid, update-data.sn
		response = {result-code: 0, error-message: null}
		[response.result-code, response.error-message] = [err.number, err.descrition] if err

		callback response
	
create-user-and-mining-interesting-info = !(user-data, callback) ->
	(user) <-! Users.create-user-with-contacts user-data
	(info) <-! Users.mining-interesting-info user
	callback user, info

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

module.exports <<< User-manager