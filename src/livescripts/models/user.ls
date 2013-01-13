require! ['../servers-init'.orm, '../servers-init'.S]

User = orm.define 'User', 
	uid: {type: S.STRING, unique:true}
	name: S.STRING
	isRegistered: S.BOOLEAN
	isMerged: S.BOOLEAN,
	* 
		classMethods:
			create-user-with-phone: !(user-data, phone-data, callback) ->
				Phone.create phone-data .success !(phone) ->
					User.create user-data .success !(user) ->
						user.addPhone phone .success !->
							user.save!.success !->
								callback user
							.error !(err) ->
								throw new Error err if err

			get-or-create-user-with-phone: !(user-data, phone-data, callback) ->
				Phone.find {where: {number: phone-data.number}} .success !(phone) ->
					if phone
						phone.get-own-by! .success !(owner) ->
							# TODO: check user against owner
							callback owner
					else
						debugger;
						User.create-user-with-phone user-data, phone-data, callback
				.error !(err) ->
					throw new Erro err if err

		

		instanceMethods: 
			bind-has-contact: (contact, callback) ->
				that = @ # LiveScript的 ~> 这里不适合，会将this绑定到当前上下文，而不是user
				that.add-has-contact contact .success !->
					contact.set-own-by that .success !->
						that.save!.success !->
							contact.save!.success !->
								callback!

			bind-as-contact: (contact, callback) ->
				that = @ 
				that.add-as-contact contact .success !->
					contact.set-act-by that .success !->
						that.save!.success !->
							contact.save!.success !->
								callback!

(exports ? this) <<< {User}	

require! ['./contact'.Contact, './phone'.Phone, './social-network'.SocialNetwork]

User.hasMany Contact, 
	as: 'hasContacts'
	foreign-key: 'own_by_user_id'
User.hasMany Contact, 
	as: 'asContacts'
	foreign-key: 'act_by_user_id'
User.hasMany Phone, {as: 'phones'}
User.hasMany SocialNetwork, {as: 'socials'}



