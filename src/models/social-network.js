var orm, S, SocialNetwork;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
SocialNetwork = orm.define('SocialNetwork', {
  account: S.STRING,
  nickname: S.STRING,
  appkey: S.STRING
}, {
  classMethods: {
    createSocialNetwork: function(socialData, callback){
      var social;
      social = {
        account: socialData.AccountName,
        nickname: null,
        appkey: null
      };
      SocialNetwork.create(social).success(function(sn){
        callback(sn);
      });
    }
  },
  instanceMethods: {}
});
(typeof exports != 'undefined' && exports !== null ? exports : this).SocialNetwork = SocialNetwork;