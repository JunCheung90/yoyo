require! ['../servers-init'.orm, '../servers-init'.S, '../util', './user'.User]

Contact = orm.define 'Contact', 
	cid: {type: S.STRING, unique: true}
	name: S.STRING
	isMerged: S.BOOLEAN
	* 
		classMethods: 
			create-as-user: (contact-register-data, callback) ->
				contact-data = { cid: util.get-UUid!, name: contact-register-data.Name, is-merged: false }
				phone-data = { number: contact-register-data.CurrentPhone, is-active: true }
				Contact.create-as-user-with-contact-phone-data contact-data, phone-data, callback

			create-as-user-with-contact-phone-data: (contact-data, phone-data, callback) ->
				user-data = { uid: util.get-UUid!, name: null, is-registered: false, is-merged: false }
				# 如果找不到Contact对应的User，则需要新建一个无名的User。
				# TODO：注意：此时User并不应该设置Phone，Contact才应当设置。现在是直接将Phone建立在了User上，需要改进。
				(user) <-! User.get-or-create-user-with-phone user-data, phone-data
				Contact.create contact-data .success !(contact) ->
					<-! user.bind-as-contact contact
					callback contact

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