require! ['should', 'async',
					'../../src/servers-init'.orm, 
					'../../src/models/user'.User,
					'../../src/models/phone'.Phone,
					'../../src/models/contact'.Contact,
					'../../src/orm-sync'.drop-create-orm]

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'Sequelize 用法', !->
	do
		(done) <-! before
		<-! drop-create-orm
		done!


	contact-data = {cid: '456', name: '李四', isMerged: false}
	contact-phone = {number: 34567890, isActive: true}

	can '创建User', !(done) ->
		user-data = {uid: '123', name: '张三', isRegistered: false, isMerged:false}
		phone-data = {number: 1234567, isActive: true}

		(user) <-! User.create-user-with-phone user-data, phone-data
		User.find {where: {name: '张三'}} .success !(found-user) ->
			# sequelize对createAt和updateAt的处理比较奇怪，found-user和user
			# 在这里会不一样。should包中的eql方法是逐一比较各个属性值的，故而这里
			# 采用比较uid和name的方式
			found-user.uid.should.eql user.uid
			found-user.name.should.eql user.name
			console.log "\n\t成功创建了User：#{user.name}"
			done!

	can '添加Contact' !(done) ->
		contact-data = {cid: '456', name: '李四', isMerged: false}
		contact-phone = {number: 34567890, isActive: true}
		User.find {where: {name: '张三'}} .success !(user) ->
			(contact) <-! Contact.create-as-user-with-contact-phone-data contact-data, contact-phone
			<-! user.bind-has-contact contact
			User.find {where: {name: '张三'}} .success !(found-user) ->
			user.get-has-contacts! .success !(contacts) ->
				process.stdout.write "\n\t找回的User：#{user.name}有#{contacts.length}个联系人："
				contacts.length.should.eql 1
				(err) <-! async.for-each contacts, !(contact, next) ->
					process.stdout.write "#{contact.name}\t"
					next!
				console.log "\n\t成功添加了Contact：#{contact.name}"
				done!