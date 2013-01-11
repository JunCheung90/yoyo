require! ['should'
					'../../output/servers-init'.orm, 
					'../../src/models/user'.User,
					'../../src/models/phone'.Phone]

desrcibe 'Sequelize 用法', !->
	(done) <-! before
	do
		orm.sync!
		done!

	user-data = {uid: '123', name: '张三', isRegistered: false, isMerged:false}
	phone-data = {number: 1234567, isActive: false}

	it '创建User', !(done) ->
	Phone.create phone-data .success !(phone) ->
		User.create user-data .success !(user) ->
			user.addPhone phone .success !->
				done!
			.error !(err) ->
				should.not.exist err
				done!
		.error !(err) ->
			should.not.exist err
			done!


