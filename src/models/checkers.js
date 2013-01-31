if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
var _, Checkers;
_ = require('underscore');
Checkers = {
  same: function(v1, v2){
    var ref$;
    if ((v1 != null ? (ref$ = v1[0]) != null ? ref$.account : void 8 : void 8) === 'zhangsan111') {
      console.log("\n\n*************** v1: %j, v2: %j, result %j ***************\n\n", v1, v2, _.isEqual(v1, v2));
    }
    if (!v1 || !v2 || (_.isArray(v1) && v1.length === 0 && _.isArray(v2) && v2.length === 0)) {
      return false;
    }
    return _.isEqual(v1, v2);
  },
  similarName: function(a, b){
    return false;
  },
  sameOwnerDifProvider: function(a, b){
    return false;
  }
};
module.exports = Checkers;