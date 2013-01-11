require! ['../servers-init'.orm, 
					'../servers-init'.S,
					'./phone', 'social-network', 'contacts-merge-record']

Contact = orm.define 'Contact', 
	uid: {type: S.STRING, unique: true}
	name: S.STRING
	* 
		classMethods: {}
		instanceMethods: {}

Contact.hasMany Phone, {as: 'phones'}
Contact.hasMany SocialNetwork, {as: 'socials'}
Contact.hasOne ContactsMergeRecord, {as: 'mergedToContact'}

(exports ? this) <<< {Contact}