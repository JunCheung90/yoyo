if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var orm, user, phone, dropCreateOrm;
orm = require('./servers-init').orm;
user = require('./models/user');
phone = require('./models/phone');
dropCreateOrm = function(callback){
  orm.sync({
    force: true
  }).success(function(){
    orm.options.logging = false;
    callback();
  });
};
(typeof exports != 'undefined' && exports !== null ? exports : this).dropCreateOrm = dropCreateOrm;