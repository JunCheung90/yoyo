var orm, S, User, Contact, Phone, SocialNetwork;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
User = orm.define('User', {
  uid: {
    type: S.STRING,
    unique: true
  },
  name: S.STRING,
  isRegistered: S.BOOLEAN,
  isMerged: S.BOOLEAN
}, {
  classMethods: {},
  instanceMethods: {}
});
(typeof exports != 'undefined' && exports !== null ? exports : this).User = User;
Contact = require('./contact').Contact;
Phone = require('./phone').Phone;
SocialNetwork = require('./social-network').SocialNetwork;
User.hasMany(Contact, {
  as: 'hasContacts',
  foreignKey: 'own_by_user_id'
});
User.hasMany(Contact, {
  as: 'asContacts',
  foreignKey: 'act_by_user_id'
});
User.hasMany(Phone, {
  as: 'phones'
});
User.hasMany(SocialNetwork, {
  as: 'socials'
});