require! ['../servers-init'.orm, '../servers-init'.S]

Contact = orm.define 'Contact', 
	uid: {type: S.STRING, unique: true}
	name: S.STRING
	* 
		classMethods: {}
		instanceMethods: {}

(exports ? this) <<< {Contact}

require! ['./phone'.Phone, './social-network'.SocialNetwork, './contacts-merge-record'.ContactsMergeRecord]

Contact.hasMany Phone, {as: 'phones'}
Contact.hasMany SocialNetwork, {as: 'socials'}
Contact.hasOne ContactsMergeRecord, {as: 'mergedToContact'}