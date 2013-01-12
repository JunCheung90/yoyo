var orm, S, ContactsMergeRecord, Contact;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
ContactsMergeRecord = orm.define('ContactsMergeRecord', {
  reason: S.STRING,
  effectiveTime: S.DATE,
  state: S.STRING
}, {
  classMethods: {},
  instanceMethods: {}
});
(typeof exports != 'undefined' && exports !== null ? exports : this).ContactsMergeRecord = ContactsMergeRecord;
Contact = require('./contact').Contact;
ContactsMergeRecord.hasMany(Contact, {
  as: 'toBeMergedContacts'
});