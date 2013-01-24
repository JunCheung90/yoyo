require! [async, '../util']

create-user-with-contacts = !(db, user-data, callback)->
	# 不论系统中目前此用户是否已经注册，总是生成一个新的user，然后判断原有用户中有无重复用户，如果有就merge到这个用户。
	# 如果系统中此用户尚未注册过，则新建user。
	user = {} <<< user-data
	build-user-basic-info user
	debugger;
	(is-merged) <-! merge-same-users db, user
	if not is-merged # 没有重复用户，需要新建
		<-! new-user-with-contacts db, user  
		callback user
	else
		callback user

build-user-basic-info = !(user)->
	current = new Date!.get-time!
	user.uid = util.get-UUid!
	user.is-registered = true
	user.last-modified-date = current
	user.merge-status = 'NONE'
	user.merge-to = null
	user.merge-from = []

	user.avatars = [create-default-system-avatar user] if not user?.avatar?.length
	user.current-avatar = user.avatars[0]
	[phone.start-using-time = current for phone in user.phones]

create-default-system-avatar = (user) ->
	#TODO:
	console.log "create-default-system-avatar NOT IMPLEMENTED!"

merge-same-users = !(db, user, callback) ->
	#TODO:
	console.log "merge-same-users NOT IMPLEMENTED!"
	callback false # TODO: 现在默认不合并用户

new-user-with-contacts = !(db, user, callback) ->
	user.as-contact-of = []
	user.contacted-strangers = []
	user.contacted-by-strangers = []	
	if user.is-person = is-person user # 人类
		<-!	create-contacts db, user # 联系人更新（识别为user，或创建为user）后，方回调。
		(err, result) <-! db.users.insert user
		throw new Error err if err
		async-get-api-keys db, user
		callback user
	else # 单位
		(err, result) <-! db.users.insert user
		throw new Error err if err
		callback user

is-person = (user) ->
	# TODO: 判断用户是否是人，而不是单位。这里通过手机来注册，一般都是人类。
	true

create-contacts = !(db, user, callback) ->
	user.contacts-seq = 0
	to-create-contact-users = []
	(err) <-! async.for-each user.contacts, !(contact, next) ->
		contact.cid = create-cid user.uid, ++user.contacts-seq
		(err, contact-user) <-! db.users.find({phones: {$all: contact.phones}}).toArray
		# TODO: 需要处理联系人号码不对的情况。看看通话历史当中是否有过对应号码的通话。
		throw new Error "#{contact} refers to more than one user: #{contact-user}" if contact-user?.length > 1
		to-create-contact-users.push contact if not contact-user?.length
		next!
	<-! create-contacts-users db, to-create-contact-users 	
	callback!

create-contacts-users = !(db, contacts, callback) ->
	users = []
	for contact in contacts
		user = {phones, emails, ims, sns} = contact
		contact.uid = user.uid = util.get-UUid!
		user.is-registered = false
		users.push user
	(err, users) <-! db.users.insert users
	throw new Error err if err
	callback!

create-cid = (uid, seq-no) ->
	uid + '-c-' + new Date!.get-time! + '-' + seq-no

async-get-api-keys = !(db, user)-> # 异步方法，完成之后会存储user。
	(err) <-! async.for-each user.ims, !(im, next) ->
		(api-key) <-! async-get-im-api-key im
		im.api-key = api-key
		next!
	throw new Error err if err

	(err) <-! async.for-each user.sns, !(sn, next) ->
		(api-key) <-! async-get-sn-api-key sn
		sn.api-key = api-key
		next!
	throw new Error err if err

	(err, user) <-! db.users.save user
	throw new Error err if err

async-get-im-api-key = !(im, callback) ->
	# TODO: 
	callback!

async-get-sn-api-key = !(sn, callback) ->
	# TODO: 
	callback!

(exports ? this) <<< {create-user-with-contacts}	