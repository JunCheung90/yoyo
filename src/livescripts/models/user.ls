require! ['../servers-init'.orm, '../servers-init'.S]

User = orm.define 'User', 
	uid: {type: S.STRING, unique:true}
	name: S.STRING
	isRegistered: S.BOOLEAN
	isMerged: S.BOOLEAN,
	* 
		classMethods: {}
		instanceMethods: {}

(exports ? this) <<< {User}	

require! ['./contact'.Contact, './phone'.Phone, './social-network'.SocialNetwork]

User.hasMany Contact, {as: 'contactsHas'}
User.hasMany Contact, {as: 'contactsAs'}
User.hasMany Phone, {as: 'phones'}
User.hasMany SocialNetwork, {as: 'socials'}



