require! ['../servers-init'.orm, '../servers-init'.S]

Phone = orm.define 'Phone', 
	number: S.STRING
	isActive: S.BOOLEAN
	* 
		classMethods: {}
		instanceMethods: {}

(exports ? this) <<< {Phone}	

require! ['./user'.User]
Phone.belongsTo User, {as: 'ownBy'}
