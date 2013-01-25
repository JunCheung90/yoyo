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

	can '创建User张三，张三有2个Contacts，作为别人的0个Contact。', !(done) ->
		<-! check-create-user-with 'zhangsan.json', '张三'
		check-user-contacts '张三', 2, 0, done

	can '创建User李四，李四有2个Contacts，作为别人的1个Contact。', !(done) ->
		<-! check-create-user-with 'lisi.json', '李四'
		check-user-contacts '李四', 2, 1, done


	can '创建User赵五，赵五有3个Contacts，作为别人的2个Contacts。', !(done) ->
		<-! check-create-user-with 'zhaowu.json', '赵五'
		check-user-contacts '赵五', 3, 2, done


	can '最新张三联系人情况，有2个Contacts，作为别人的3个Contacts' !(done) ->
		check-user-contacts '张三', 2, 3, done	

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


!function	check-user-contacts user-name, amount-of-has-contacts, amount-of-as-contacts, callback
	(err, found-users) <-! db.users.find({name: user-name}).to-array
	found-users.length.should.eql 1
	found-user = found-users[0]
	found-user.contacts.length.should.eql amount-of-has-contacts
	console.log "\n\t找回的User：#{user-name}有#{found-user.contacts.length}个联系人：%j", [[name for name in contact.names] for  contact in found-user.contacts]

	found-user.as-contact-of.length.should.eql amount-of-as-contacts
	console.log "\n\t找回的User：#{user-name}作为#{found-user.as-contact-of.length}个联系人：%j", [[name for name in contact.names] for  contact in found-user.as-contact-of]

	console.log "\n\t找回的User：#{user-name}有#{found-user.sns.length}个SN：%j" [{sn.sn-name, sn.account-name} for sn in found-user.sns]

	callback!			

