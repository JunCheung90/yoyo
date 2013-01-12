var orm, S, Phone;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
Phone = orm.define('Phone', {
  number: S.STRING,
  isActive: S.BOOLEAN
}, {
  classMethods: {},
  instanceMethods: {}
});
(typeof exports != 'undefined' && exports !== null ? exports : this).Phone = Phone;