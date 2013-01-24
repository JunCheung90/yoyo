require! ['should', 'async', 
					'../../src/models/User',
					'../../src/servers-init'.init-mongo-client, 
					'../../src/servers-init'.shutdown-mongo-client]

[db, client] = [null null]

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'mongoDb版的注册用户', !->
	do
		(done) <-! before
		(mongo-client, mongo-db) <-! init-mongo-client
		[db, client] := [mongo-db, mongo-client]
		<-! db.drop-collection 'users'
		done!

	can '创建User张三', !(done) ->
		check-create-user-with 'zhangsan.json', '张三', done

	# can '添加张三Contacts后，张三有2个Contacts，作为别人的0个Contact' !(done) ->
	# 	<-! create-user-contacts 'zhangsan.json', '张三'
	# 	check-user-contacts '张三', 2, 0, done	

	# can '创建User李四', !(done) ->
	# 	check-create-user-with 'lisi.json', '李四', done

	# can '添加李四Contacts后，李四有2个Contacts，作为别人的1个Contact' !(done) ->
	# 	<-! create-user-contacts 'lisi.json', '李四'
	# 	check-user-contacts '李四', 2, 1, done							

	# can '创建User赵五', !(done) ->
	# 	check-create-user-with 'zhaowu.json', '赵五', done

	# can '添加赵五Contacts后，赵五有3个Contacts，作为别人的2个Contacts' !(done) ->
	# 	<-! create-user-contacts 'zhaowu.json', '赵五'
	# 	check-user-contacts '赵五', 3, 2, done		

	# can '最新张三联系人情况，有2个Contacts，作为别人的3个Contacts' !(done) ->
	# 	check-user-contacts '张三', 2, 3, done	

	do
		(done) <-! after
		<-! shutdown-mongo-client client
		done!

!function check-create-user-with json-file-name, user-name, callback
	user-data = require "../test-data/#{json-file-name}"
	(user) <-! User.create-user-with-contacts db, user-data
	(err, found-users) <-! db.users.find({name: '张三'}).to-array
	found-users.length.should.eql 1
	found-users[0].name.should.eql user.name
	console.log "\n\t成功创建了User：#{user.name}"
	callback!

!function create-user-contacts json-file-name, user-name, callback
	contacts-data = (require "../test-data/#{json-file-name}").Contacts
	User.find {where: {name: user-name}} .success !(user) ->
		<-! user.create-and-bind-contacts contacts-data
		callback!


!function	check-user-contacts user-name, amount-of-has-contacts, amount-of-as-contacts, callback
	User.find {where: {name: user-name}} .success !(found-user) ->
		found-user.get-has-contacts! .success !(contacts) ->
			console.log "\n\t找回的User：#{user-name}有#{contacts.length}个联系人："
			contacts.length.should.eql amount-of-has-contacts
			(err) <-! async.for-each contacts, !(contact, next) ->
				console.log "\t#{contact.name}"
				next!
			throw new Error err if err
			found-user.get-as-contacts! .success !(contacts) ->
				console.log "\n\t找回的User：#{user-name}充当#{contacts.length}个联系人："
				contacts.length.should.eql amount-of-as-contacts
				(err) <-! async.for-each contacts, !(contact, next) ->
					console.log "\t#{contact.name}"
					next!
				throw new Error err if err
				found-user.get-socials! .success !(socials) ->
					console.log "\n\t找回的User：#{user-name}有#{socials.length}个SN："
					(err) <-! async.for-each socials, !(social, next) ->
						console.log "\t#{social.account}"
						next!
					callback!			

