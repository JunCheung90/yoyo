var orm, S, phone, socialNetwork, contactsMergeRecord, Contact;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
phone = require('./phone');
socialNetwork = require('social-network');
contactsMergeRecord = require('contacts-merge-record');
Contact = orm.define('Contact', {
  uid: {
    type: S.STRING,
    unique: true
  },
  name: S.STRING
}, {
  classMethods: {},
  instanceMethods: {}
});
Contact.hasMany(Phone, {
  as: 'phones'
});
Contact.hasMany(SocialNetwork, {
  as: 'socials'
});
Contact.hasOne(ContactsMergeRecord, {
  as: 'mergedToContact'
});
(typeof exports != 'undefined' && exports !== null ? exports : this).Contact = Contact;