var should, async, orm, User, Phone, Contact, dropCreateOrm, can;
should = require('should');
async = require('async');
orm = require('../../src/servers-init').orm;
User = require('../../src/models/user').User;
Phone = require('../../src/models/phone').Phone;
Contact = require('../../src/models/contact').Contact;
dropCreateOrm = require('../../src/orm-sync').dropCreateOrm;
can = it;
describe('Sequelize 用法', function(){
  var contactData, contactPhone;
  before(function(done){
    dropCreateOrm(function(){
      done();
    });
  });
  contactData = {
    cid: '456',
    name: '李四',
    isMerged: false
  };
  contactPhone = {
    number: 34567890,
    isActive: true
  };
  can('创建User', function(done){
    var userData, phoneData;
    userData = {
      uid: '123',
      name: '张三',
      isRegistered: false,
      isMerged: false
    };
    phoneData = {
      number: 1234567,
      isActive: true
    };
    User.createUserWithPhone(userData, phoneData, function(user){
      User.find({
        where: {
          name: '张三'
        }
      }).success(function(foundUser){
        foundUser.uid.should.eql(user.uid);
        foundUser.name.should.eql(user.name);
        console.log("\n\t成功创建了User：" + user.name);
        done();
      });
    });
  });
  can('添加Contact', function(done){
    var contactData, contactPhone;
    contactData = {
      cid: '456',
      name: '李四',
      isMerged: false
    };
    contactPhone = {
      number: 34567890,
      isActive: true
    };
    User.find({
      where: {
        name: '张三'
      }
    }).success(function(user){
      Contact.createAsUserWithContactPhoneData(contactData, contactPhone, function(contact){
        user.bindHasContact(contact, function(){
          User.find({
            where: {
              name: '张三'
            }
          }).success(function(foundUser){});
          user.getHasContacts().success(function(contacts){
            process.stdout.write("\n\t找回的User：" + user.name + "有" + contacts.length + "个联系人：");
            contacts.length.should.eql(1);
            async.forEach(contacts, function(contact, next){
              process.stdout.write(contact.name + "\t");
              next();
            }, function(err){
              console.log("\n\t成功添加了Contact：" + contact.name);
              done();
            });
          });
        });
      });
    });
  });
});