var orm, S, SocialNetwork;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
SocialNetwork = orm.define('SocialNetwork', {
  account: S.STRING,
  nickname: S.STRING,
  appkey: S.STRING
}, {
  classMethods: {},
  instanceMethods: {}
});