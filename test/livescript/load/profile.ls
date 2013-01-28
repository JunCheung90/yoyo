/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['should', 'async', 
          '../../src/models/User',
          '../../src/servers-init'.init-mongo-client, 
          '../../src/servers-init'.shutdown-mongo-client,
          '../../src/util']

[db, client] = [null null]

MULTIPLE-TIMES = 1000

do
  (mongo-client, mongo-db) <-! init-mongo-client
  [db, client] := [mongo-db, mongo-client]
  <-! db.drop-collection 'users'
  <-! create-and-check-user 'zhangsan.json', '张三', MULTIPLE-TIMES
  <-! create-and-check-user 'lisi.json', '李四', MULTIPLE-TIMES
  <-! create-and-check-user 'zhaowu.json', '赵五', MULTIPLE-TIMES
  <-! shutdown-mongo-client client


!function create-and-check-user json-file-name, user-name, fake-contacts-amount, callback

  user-data = util.load-json __dirname + "/../test-data/#{json-file-name}"
  user-data = multiple-contacts-data user-data, fake-contacts-amount
  console.log "\n\n*************** #{user-name} has #{user-data.contacts.length} contacts. ************************\n\n"
  start-time = new Date!
  (user) <-! User.create-user-with-contacts db, user-data
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-users[0].name.should.eql user-name
  end-time = new Date!
  console.log "\n\t 耗费时间 #{end-time - start-time}"
  callback! 

function multiple-contacts-data user-data, contacts-amount
  for i from 1 to contacts-amount
    user-data.contacts.push generate-fake-contact!
  user-data

function generate-fake-contact
  fake-contact =
    "phones":
      * Math.random! * 100000
        ...

!function check-user-contacts user-name, amount-of-has-contacts, amount-of-as-contacts, callback
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-user = found-users[0]
  found-user.contacts.length.should.eql amount-of-has-contacts
  # console.log "\n\t找回的User：#{user-name}有#{found-user.contacts.length}个联系人：%j", [[name for name in contact.names] for  contact in found-user.contacts]

  found-user.as-contact-of.length.should.eql amount-of-as-contacts
  console.log "\n\t找回的User：#{user-name}作为#{found-user.as-contact-of.length}个联系人"

  console.log "\n\t找回的User：#{user-name}有#{found-user.sns.length}个SN：%j" [{sn.sn-name, sn.account-name} for sn in found-user.sns]

  callback!     

