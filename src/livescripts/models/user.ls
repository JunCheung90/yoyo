require! ['../servers-init'.orm, 
					'../servers-init'.S,
					'./contact', './phone', './social-network']

User = orm.define 'User', 
	uid: {type: S.STRING, unique:true}
	name: S.STRING
	isRegistered: S.BOOLEAN
	isMerged: S.BOOLEAN,
	* 
		classMethods: {}
		instanceMethods: {}

User.hasMany Contact, {as: 'contactsHas'}
User.hasMany Contact, {as: 'contactsAs'}
User.hasMany Phone, {as: 'phones'}
User.hasMany SocialNetwork, {as: 'socials'}

(exports ? this) <<< {User}			


