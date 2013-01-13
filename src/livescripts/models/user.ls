require! [async, '../servers-init'.orm, '../servers-init'.S, '../util']

User = orm.define 'User', 
	uid: {type: S.STRING, unique:true}
	name: S.STRING
	isRegistered: S.BOOLEAN
	isMerged: S.BOOLEAN,
	* 
		classMethods:
			get-or-create-user-with-register-data: !(register-data, callback) ->
				phone-data = { number: register-data.User.CurrentPhone, is-active: true }
				user-data = { uid: util.get-UUid!, name: register-data.User.Name, is-registered: true, is-merged: false }
				(user) <-! User.get-or-create-user-with-phone user-data, phone-data
				callback user
				
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
						phone.get-own-by! .success !(user) ->
							return callback user if user.isRegistered  
							<-! user.update user-data # 用户之前并未注册，而是作为他人的联系人，由系统生成的用户，此时需要补充注册信息。
							callback user
					else
						User.create-user-with-phone user-data, phone-data, callback
				.error !(err) ->
					throw new Erro err if err

		instanceMethods: 
			bind-has-contact: !(contact, callback) ->
				that = @ # LiveScript的 ~> 这里不适合，会将this绑定到当前上下文，而不是user
				that.add-has-contact contact .success !->
					contact.set-own-by that .success !->
						that.save!.success !->
							contact.save!.success !->
								callback!

			bind-as-contact: !(contact, callback) ->
				that = @ 
				that.add-as-contact contact .success !->
					contact.set-act-by that .success !->
						that.save!.success !->
							contact.save!.success !->
								callback!

			update: !(user-data, callback) ->
				that = @ 
				that.name = user-data.name 
				that.is-registered = user-data.is-registered
				that.save!.success !->
					callback!

			create-and-bind-contacts: !(contacts-register-data, callback) ->
				that = @
				(err) <-! async.for-each contacts-register-data, !(contact-register-data, next) ->
					(contact) <-! Contact.create-as-user contact-register-data
					<-!  that.bind-has-contact contact
					next!
				throw new Error err if err
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