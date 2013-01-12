var orm, S, Phone, User;
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
User = require('./user').User;
Phone.belongsTo(User, {
  as: 'ownBy'
});