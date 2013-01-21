require! '../servers-init'.couch

get-contact-by-id = !(contact-id, callback) ->
	do
		(err, req, res, data) <-! couch.get '/test_db/my_contacts'
		throw new Error(err) if err
		for contact, i in data.Contacts 
			result = contact if contact.id == contact-id
		callback contact

store-contacts = !(contacts, callback) ->
	console.log "#{&.callee.name} is NOT IMPLEMENTED YET!"
	callback!

merge-contacts = !(contacts, callback) ->
	console.log "#{&.callee.name} is NOT IMPLEMENTED YET!"
	callback!

update-contact-doc = !(contacts, callback) ->
	console.log "#{&.callee.name} is NOT IMPLEMENTED YET!"
	callback!

# 输出模块 root的作用参考：http://stackoverflow.com/questions/4214731/coffeescript-global-variables
# root = exports ? this
# root = {get-contact-by-id, store-contacts, merge-contacts, update-contact-doc}

(exports ? this) <<< {get-contact-by-id, store-contacts, merge-contacts, update-contact-doc}

