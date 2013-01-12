require! ['../servers-init'.orm, '../servers-init'.S]

Contact = orm.define 'Contact', 
	cid: {type: S.STRING, unique: true}
	name: S.STRING
	isMerged: S.BOOLEAN
	* 
		classMethods: {}
		instanceMethods: {}

(exports ? this) <<< {Contact}

require! ['./user'.User, './phone'.Phone, 
	'./social-network'.SocialNetwork, './contacts-merge-record'.ContactsMergeRecord]

Contact.hasMany Phone, {as: 'phones'}
Contact.hasMany SocialNetwork, {as: 'socials'}
Contact.hasOne ContactsMergeRecord, {as: 'mergedToContact'}

Contact.belongsTo User, 
	as: 'ownBy'
	foreign-key: 'own_by_user_id'
Contact.belongsTo User, 
	as: 'actBy'
	foreign-key: 'act_by_user_id'