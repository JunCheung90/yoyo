require! ['should'
					'../../src/servers-init'.orm, 
					'../../src/models/user'.User,
					'../../src/models/phone'.Phone]

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'Sequelize 用法', !->
	do
		(done) <-! before
		orm.sync {force: true} .success !->
			done!

	user-data = {uid: '123', name: '张三', isRegistered: false, isMerged:false}
	phone-data = {number: 1234567, isActive: false}

	can '创建User', !(done) ->
		Phone.create phone-data .success !(phone) ->
			User.create user-data .success !(user) ->
				user.addPhone phone .success !->
					user.save!.success !->
						console.log '成功创建了 %j' user
						done!
