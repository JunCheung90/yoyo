require! ['../servers-init'.orm, 
					'../servers-init'.S]

SocialNetwork = orm.define 'SocialNetwork', 
	account: S.STRING
	nickname: S.STRING
	appkey: S.STRING
	* 
		classMethods: {}
		instanceMethods: {}