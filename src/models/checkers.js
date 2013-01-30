var _, Checkers;
_ = require('underscore');
Checkers = {
  same: function(v1, v2){
    if (_.isArray(v1)) {
      if (!_.isEmpty(_.intersection(v1, v2))) {
        return true;
      }
    } else {
      if (_.isEqual(v1, v2)) {
        return true;
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