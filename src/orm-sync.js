var orm, user, phone, dropCreateOrm;
orm = require('./servers-init').orm;
user = require('./models/user');
phone = require('./models/phone');
dropCreateOrm = function(callback){
  orm.options.logging = true;
  return orm.sync({
    force: true
  }).success(function(){
    console.log('Success Sync ORM');
    orm.options.logging = false;
    callback();
  });
};
(typeof exports != 'undefined' && exports !== null ? exports : this).dropCreateOrm = dropCreateOrm;