var orm = require('../../src/servers-init').orm
	, model = require('../../src/models/User')
	,	User = model.User
	,	Phone = model.Phone
  , should = require('should');


describe('Sequelize 用法', function(){

	before(function(done){
		orm.sync();
		done();
	});

	it('创建User', function(done){
	debugger
		Phone.create({
			number: 12345657,
			isActive: false
		}).success(function(phone){
			User.create({
				uid: '123',
				name: '张三',
				isRegistered: false,
				isMerged: false
			}).success(function(user){
				user.addPhone(phone).success(function(){
					user.save().success(function(){
						done();
					}).error(function(err){
						should.not.exist(err);
						done();
					})
				}).error(function(err){
					should.not.exist(err);
					done();
				})
				
			})

			
		})

	})
});

