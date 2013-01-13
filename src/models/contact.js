var orm, S, util, User, Contact, Phone, SocialNetwork, ContactsMergeRecord;
orm = require('../servers-init').orm;
S = require('../servers-init').S;
util = require('../util');
User = require('./user').User;
Contact = orm.define('Contact', {
  cid: {
    type: S.STRING,
    unique: true
  },
  name: S.STRING,
  isMerged: S.BOOLEAN
}, {
  classMethods: {
    createAsUser: function(contactRegisterData, callback){
      var contactData, phoneData;
      contactData = {
        cid: util.getUUid(),
        name: contactRegisterData.Name,
        isMerged: false
      };
      phoneData = {
        number: contactRegisterData.CurrentPhone,
        isActive: true
      };
      return Contact.createAsUserWithContactPhoneData(contactData, phoneData, callback);
    },
    createAsUserWithContactPhoneData: function(contactData, phoneData, callback){
      var userData;
      userData = {
        uid: util.getUUid(),
        name: null,
        isRegistered: false,
        isMerged: false
      };
      return User.getOrCreateUserWithPhone(userData, phoneData, function(user){
        Contact.create(contactData).success(function(contact){
          user.bindAsContact(contact, function(){
            callback(contact);
          });
        });
      });
    }
  },
  instanceMethods: {}
});
(typeof exports != 'undefined' && exports !== null ? exports : this).Contact = Contact;
User = require('./user').User;
Phone = require('./phone').Phone;
SocialNetwork = require('./social-network').SocialNetwork;
ContactsMergeRecord = require('./contacts-merge-record').ContactsMergeRecord;
Contact.hasMany(Phone, {
  as: 'phones'
});
Contact.hasMany(SocialNetwork, {
  as: 'socials'
});
Contact.hasOne(ContactsMergeRecord, {
  as: 'mergedToContact'
});
Contact.belongsTo(User, {
  as: 'ownBy',
  foreignKey: 'own_by_user_id'
});
Contact.belongsTo(User, {
  as: 'actBy',
  foreignKey: 'act_by_user_id'
});