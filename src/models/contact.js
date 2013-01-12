var orm, S, Contact, User, Phone, SocialNetwork, ContactsMergeRecord;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
Contact = orm.define('Contact', {
  cid: {
    type: S.STRING,
    unique: true
  },
  name: S.STRING,
  isMerged: S.BOOLEAN
}, {
  classMethods: {},
  instanceMethods: {}
});
(typeof exports != 'undefined' && exports !== null ? exports : this).Contact = Contact;
User = require('./user').User;
Phone = require('./phone').Phone;
SocialNetwork = require('./social-network').SocialNetwork;
ContactsMergeRecord = require('./contacts-merge-record').ContactsMergeRecord;
Contact.hasMany(Phone, {
  as: 'phones'
});
Contact.hasMany(SocialNetwork, {
  as: 'socials'
});
Contact.hasOne(ContactsMergeRecord, {
  as: 'mergedToContact'
});
Contact.belongsTo(User, {
  as: 'ownBy',
  foreignKey: 'own_by_user_id'
});
Contact.belongsTo(User, {
  as: 'actBy',
  foreignKey: 'act_by_user_id'
});