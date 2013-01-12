require! ['should', 'async',
					'../../src/servers-init'.orm, 
					'../../src/models/user'.User,
					'../../src/models/phone'.Phone,
					'../../src/orm-sync'.drop-create-orm]

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'Sequelize 用法', !->


	can '查找User' !(done) ->
		User.find {where: {name: '张三'}} .success !(user) ->
			console.log '\n成功找到了User %j' user
			user.get-has-contacts! .success !(contacts) ->
				console.log "\n找到#{contacts.length}个has联系人"
				(err) <-! async.for-each contacts, !(contact, next) ->
					console.log "\n成功找到了User: #{user.name}，的联系人：#{contact.name}"
					next!
				user.get-as-contacts! .success !(contacts) ->
					console.log "\n找到#{contacts.length}个as联系人"
					(err) <-! async.for-each contacts, !(contact, next) ->
						console.log "\n成功找到了User: #{user.name}，act as的联系人：#{contact.name}"
						next!
					done!

			# user.getPhones! .success !(phones) ->
			# 	(err) <-! async.for-each phones, !(phone, next) ->
			# 		phone.get-own-by! .success !(user) ->
			# 			console.log "\n成功找到了Phone: #{phone.number}，和对应的User：#{user.name}"
			# 			next!
			# 	throw new Error err if err
			# 	done!
		.error !(err) ->
			console.log err
			done!
