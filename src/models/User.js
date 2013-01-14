var async, orm, S, util, User, Contact, Phone, SocialNetwork;
async = require('async');
orm = require('../servers-init').orm;
S = require('../servers-init').S;
util = require('../util');
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
    getOrCreateUserWithRegisterData: function(registerData, callback){
      var phoneData, userData, socialData;
      phoneData = {
        number: registerData.User.CurrentPhone,
        isActive: true
      };
      userData = {
        uid: util.getUUid(),
        name: registerData.User.Name,
        isRegistered: true,
        isMerged: false
      };
      socialData = registerData.User.SN;
      User.getOrCreateUserWithPhone(userData, phoneData, socialData, function(user){
        callback(user);
      });
    },
    createUserWithPhone: function(userData, phoneData, socialData, callback){
      Phone.create(phoneData).success(function(phone){
        User.create(userData).success(function(user){
          user.addPhone(phone).success(function(){
            user.addSocialNetworksWithoutSave(socialData, function(){
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
      });
    },
    getOrCreateUserWithPhone: function(userData, phoneData, socialData, callback){
      Phone.find({
        where: {
          number: phoneData.number
        }
      }).success(function(phone){
        if (phone) {
          phone.getOwnBy().success(function(user){
            if (user.isRegistered) {
              return callback(user);
            }
            user.update(userData, socialData, function(){
              callback(user);
            });
          });
        } else {
          User.createUserWithPhone(userData, phoneData, socialData, callback);
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
      that.addHasContact(contact).success(function(){
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
      that.addAsContact(contact).success(function(){
        contact.setActBy(that).success(function(){
          that.save().success(function(){
            contact.save().success(function(){
              callback();
            });
          });
        });
      });
    },
    addSocialNetworks: function(socialData, callback){
      var that;
      that = this;
      that.addSocialNetworksWithoutSave(socialData, function(){
        that.save().success(function(){
          callback();
        });
      });
    },
    addSocialNetworksWithoutSave: function(socialData, callback){
      var that;
      that = this;
      async.forEach(socialData, function(sd, next){
        SocialNetwork.createSocialNetwork(sd, function(sn){
          that.addSocial(sn).success(function(){
            next();
          });
        });
      }, function(err){
        if (err) {
          throw new Error(err);
        }
        callback();
      });
    },
    update: function(userData, socialData, callback){
      var that;
      that = this;
      that.name = userData.name;
      that.isRegistered = userData.isRegistered;
      that.addSocialNetworksWithoutSave(socialData, function(){
        that.save().success(function(){
          callback();
        });
      });
    },
    createAndBindContacts: function(contactsRegisterData, callback){
      var that;
      that = this;
      async.forEach(contactsRegisterData, function(contactRegisterData, next){
        Contact.createAsUser(contactRegisterData, function(contact){
          that.bindHasContact(contact, function(){
            next();
          });
        });
      }, function(err){
        if (err) {
          throw new Error(err);
        }
        callback();
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