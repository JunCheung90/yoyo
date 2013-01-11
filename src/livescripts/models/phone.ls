require! ['../servers-init'.orm, 
					'../servers-init'.S]

Phone = orm.define 'Phone', 
	number: S.STRING
	isActive: S.BOOLEAN
	* 
		classMethods: {}
		instanceMethods: {}