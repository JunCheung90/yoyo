var orm, S, contact, ContactsMergeRecord;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
contact = require('./contact');
ContactsMergeRecord = orm.define('ContactsMergeRecord', {
  reason: S.STRING,
  effectiveTime: S.DATE,
  state: S.STRING
}, {
  classMethods: {},
  instanceMethods: {}
});
ContactsMergeRecord.hasMany(Contact, {
  as: 'toBeMergedContacts'
});
(typeof exports != 'undefined' && exports !== null ? exports : this).ContactsMergeRecord = ContactsMergeRecord;