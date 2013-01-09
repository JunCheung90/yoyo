var orm = require('../servers-init').orm
	, S = require('../servers-init').sequelize;

var User = orm.define('User',
	{
		uid: {type: S.STRING, unique: true},
		name: S.STRING,
		isRegistered: S.BOOLEAN,
		isMerged: S.BOOLEAN,
	},
	{
		classMethods:{
		},
		instanceMethods:{
		}
	}
)

var Phone = orm.define('Phone',
	{
		number: {type: S.STRING},
		isActive: S.BOOLEAN	
	}
)

var SocialNetwork = orm.define('SocialNetwork',
	{
		account: S.STRING,
		nickname: S.STRING,
		appKey: S.STRING	
	}
)

var Contact = orm.define('Contact',
	{
		uid: {type: S.STRING, unique: true},
		name: S.STRING,
	}
)

orm.sync();

var ContactsMergeRecord = orm.define('ContactsMergeRecord',{
	reason: S.STRING,
	effectiveTime: S.DATE,
	state: S.STRING // MERGED | PENDING | REJECTED
})

User.hasMany(Phone, {as : 'phones'});
User.hasMany(SocialNetwork, {as : 'socials'});

Contact.hasMany(Phone, {as : 'phones'});
Contact.hasMany(SocialNetwork, {as : 'socials'});

User.hasMany(Contact, {as : 'contactsHas'});
User.hasMany(Contact, {as : 'contactsAs'});

ContactsMergeRecord.hasMany(Contact, {as : 'toBeMergedContacts'});
Contact.hasOne(ContactsMergeRecord, {as : 'mergedToContact'});

exports.User = User;
exports.Phone = Phone;