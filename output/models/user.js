var orm, S, contact, phone, socialNetwork, User;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
contact = require('./contact');
phone = require('./phone');
socialNetwork = require('./social-network');
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
User.hasMany(Contact, {
  as: 'contactsHas'
});
User.hasMany(Contact, {
  as: 'contactsAs'
});
User.hasMany(Phone, {
  as: 'phones'
});
User.hasMany(SocialNetwork, {
  as: 'socials'
});
(typeof exports != 'undefined' && exports !== null ? exports : this).User = User;