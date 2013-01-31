if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
var _, Checkers;
_ = require('underscore');
Checkers = {
  same: function(a, b){
    if (!a || !b || (_.isArray(a) && a.length === 0 && _.isArray(b) && b.length === 0)) {
      return false;
    }
    return _.isEqual(a, b);
  },
  oneSame: function(a, b){
    var i$, len$, eA, j$, len1$, eB;
    if (!a || !b) {
      return false;
    }
    for (i$ = 0, len$ = a.length; i$ < len$; ++i$) {
      eA = a[i$];
      for (j$ = 0, len1$ = b.length; j$ < len1$; ++j$) {
        eB = b[j$];
        if (_.isEqual(eA, eB)) {
          return true;
        }
      }
    }
    return false;
  },
  similarName: function(a, b){
    return false;
  },
  sameOwnerDifProvider: function(a, b){
    return false;
  }
};
module.exports = Checkers;