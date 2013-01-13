var orm, S, User, Contact, Phone, SocialNetwork;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
User = orm.define('User', {
  uid: {
    type: S.STRING,
    unique: true
  },
  name: S.STRING,
  isRegistered: S.BOOLEAN,
  isMerged: S.BOOLEAN
}, {
  classMethods: {
    createUserWithPhone: function(userData, phoneData, callback){
      Phone.create(phoneData).success(function(phone){
        User.create(userData).success(function(user){
          user.addPhone(phone).success(function(){
            user.save().success(function(){
              callback(user);
            }).error(function(err){
              if (err) {
                throw new Error(err);
              }
            });
          });
        });
      });
    },
    getOrCreateUserWithPhone: function(userData, phoneData, callback){
      Phone.find({
        where: {
          number: phoneData.number
        }
      }).success(function(phone){
        if (phone) {
          phone.getOwnBy().success(function(owner){
            callback(owner);
          });
        } else {
          debugger;
          User.createUserWithPhone(userData, phoneData, callback);
        }
      }).error(function(err){
        if (err) {
          throw new Erro(err);
        }
      });
    }
  },
  instanceMethods: {
    bindHasContact: function(contact, callback){
      var that;
      that = this;
      return that.addHasContact(contact).success(function(){
        contact.setOwnBy(that).success(function(){
          that.save().success(function(){
            contact.save().success(function(){
              callback();
            });
          });
        });
      });
    },
    bindAsContact: function(contact, callback){
      var that;
      that = this;
      return that.addAsContact(contact).success(function(){
        contact.setActBy(that).success(function(){
          that.save().success(function(){
            contact.save().success(function(){
              callback();
            });
          });
        });
      });
    }
  }
});
(typeof exports != 'undefined' && exports !== null ? exports : this).User = User;
Contact = require('./contact').Contact;
Phone = require('./phone').Phone;
SocialNetwork = require('./social-network').SocialNetwork;
User.hasMany(Contact, {
  as: 'hasContacts',
  foreignKey: 'own_by_user_id'
});
User.hasMany(Contact, {
  as: 'asContacts',
  foreignKey: 'act_by_user_id'
});
User.hasMany(Phone, {
  as: 'phones'
});
User.hasMany(SocialNetwork, {
  as: 'socials'
});