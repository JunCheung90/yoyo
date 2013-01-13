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

	can '创建User张三', !(done) ->
		zhangsan-data = require '../test-data/zhangsan.json'
		(user) <-! User.get-or-create-user-with-register-data zhangsan-data
		User.find {where: {name: '张三'}} .success !(found-user) ->
			# sequelize对createAt和updateAt的处理比较奇怪，found-user和user
			# 在这里会不一样。should包中的eql方法是逐一比较各个属性值的，故而这里
			# 采用比较uid和name的方式
			# found-user.uid.should.eql user.uid
			found-user.name.should.eql user.name
			console.log "\n\t成功创建了User：#{user.name}"
			done!

	can '添加张三Contact' !(done) ->
		zhangsan-contacts-data = (require '../test-data/zhangsan.json').Contacts
		User.find {where: {name: '张三'}} .success !(user) ->
			<-! user.create-and-bind-contacts zhangsan-contacts-data
			User.find {where: {name: '张三'}} .success !(found-user) ->
				found-user.get-has-contacts! .success !(contacts) ->
					console.log "\n\t找回的User：#{user.name}有#{contacts.length}个联系人："
					contacts.length.should.eql 2
					(err) <-! async.for-each contacts, !(contact, next) ->
						console.log "\t#{contact.name}"
						next!
					throw new Error err if err
					done!				

	can '创建User李四', !(done) ->
		lisi-data = require '../test-data/lisi.json'
		(user) <-! User.get-or-create-user-with-register-data lisi-data
		User.find {where: {name: '李四'}} .success !(found-user) ->
			found-user.name.should.eql user.name
			console.log "\n\t成功创建了User：#{user.name}"
			done!

	can '添加李四Contact' !(done) ->
		lisi-contacts-data = (require '../test-data/lisi.json').Contacts
		User.find {where: {name: '李四'}} .success !(user) ->
			<-! user.create-and-bind-contacts lisi-contacts-data
			User.find {where: {name: '李四'}} .success !(found-user) ->
				found-user.get-has-contacts! .success !(contacts) ->
					console.log "\n\t找回的User：#{user.name}有#{contacts.length}个联系人："
					contacts.length.should.eql 2
					(err) <-! async.for-each contacts, !(contact, next) ->
						console.log "\t#{contact.name}"
						next!
					throw new Error err if err
					found-user.get-as-contacts! .success !(contacts) ->
						console.log "\n\t找回的User：#{user.name}充当#{contacts.length}个联系人："
						contacts.length.should.eql 1
						(err) <-! async.for-each contacts, !(contact, next) ->
							console.log "\t#{contact.name}"
							next!
						throw new Error err if err
						done!								