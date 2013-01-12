var orm, S, Contact, Phone, SocialNetwork, ContactsMergeRecord;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
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
(typeof exports != 'undefined' && exports !== null ? exports : this).Contact = Contact;
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