/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 'async', 
          '../../src/models/User',
          '../../src/servers-init'.init-mongo-client, 
          '../../src/servers-init'.shutdown-mongo-client,
          '../../src/util']

[db, client] = [null null]

multiple-times = 1000

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'mongoDb版注册用户：识别用户，绑定用户（User）和联系人（Contact）', !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users'
    done! 

  can '创建User张三，张三有2个Contacts，作为0人的Contact。\n', !(done) ->
    <-! create-and-check-user 'zhangsan.json', '张三'
    check-user-contacts '张三', 2, 0, done

  can '创建User李四，李四有2个Contacts，作为1人的Contact。\n', !(done) ->
    <-! create-and-check-user 'lisi.json', '李四'
    check-user-contacts '李四', 2, 1, done


  can '创建User赵五，赵五有3个Contacts，作为2人的Contacts。\n', !(done) ->
    <-! create-and-check-user 'zhaowu.json', '赵五'
    check-user-contacts '赵五', 3, 2, done


  can '最新张三联系人情况，有2个Contacts，作为2人的Contacts。\n' !(done) ->
    check-user-contacts '张三', 2, 2, done 

  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!

describe 'mongoDb版注册用户：合并联系人', !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users'
    done! 

  can '创建User赵五。赵五的联系人两个Contacts（张大三、张老三）合并为一。\n', !(done) ->
    <-! create-and-check-user 'zhaowu.json', '赵五'
    (err, found-users) <-! db.users.find({'name': '赵五'}).to-array
    found-users.length.should.eql 1
    <-! are-contacts-merged-correct found-users[0].contacts, 1
    (err, all-users) <-! db.users.find().to-array
    all-users.length.should.eql 3
    done!

  # can '对多个重复联系人正确合并。\n', !(done) ->
  #   # 在初始数据的基础上，随机生成多个重复联系人，然后能够正确合并。
  #   (non-repeat-contacts-amount) <-! create-and-check-user-with-mulitple-repeat-contacts 'zhaowu.json', '赵五'
  #   (err, found-users) <-! db.users.find({'name': '赵五'}).to-array
  #   found-users.length.should.eql 1
  #   <-! are-contacts-merged-correct found-users[0].contacts, non-repeat-contacts-amount
  #   # (err, all-users) <-! db.users.find().to-array
  #   # all-users.length.should.eql 3
  #   done!



  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!

create-and-check-user = !(json-file-name, user-name, callback) ->
  # 这里用require，会导致第二次load json时，直接用的是缓存，而不是重新load！！
  user-data = util.load-json __dirname + "/../test-data/#{json-file-name}"
  (user) <-! User.create-user-with-contacts db, user-data
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-users[0].name.should.eql user-name
  console.log "\n\t成功创建了User：#{found-users[0].name}"
  callback! 

check-user-contacts = !(user-name, amount-of-has-contacts, amount-of-as-contacts, callback) ->
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-user = found-users[0]
  found-user.contacts.length.should.eql amount-of-has-contacts
  # console.log "\n\t找回的User：#{user-name}有#{found-user.contacts.length}个联系人：%j", [[name for name in contact.names] for  contact in found-user.contacts]

  found-user.as-contact-of.length.should.eql amount-of-as-contacts
  console.log "\n\t找回的User：#{user-name}作为#{found-user.as-contact-of.length}个联系人"

  console.log "\n\t找回的User：#{user-name}有#{found-user.sns.length}个SN：%j" [{sn.sn-name, sn.account-name} for sn in found-user.sns]

  callback!     

are-contacts-merged-correct = !(contacts, non-repeat-contacts-amount, callback) ->
  merged-result-contacts = filter is-merged-result-contact, contacts
  merged-result-contacts.length.should.eql non-repeat-contacts-amount

  # TODO: 检查merge细节正确
  # result-contact = merged-result-contacts[0]
  # result-contact.merged-from.length.should.eql 1

  callback!

is-merged-result-contact = (contact) ->
  return contact.merged-from and not contact.merge-to

create-and-check-user-with-mulitple-repeat-contacts = (json-file-name, user-name, callback)->
  user-data = util.load-json __dirname + "/../test-data/#{json-file-name}"
  non-repeat-contacts-amount = add-multiple-repeat-contacts user-data
  (user) <-! User.create-user-with-contacts db, user-data
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-users[0].name.should.eql user-name
  console.log "\n\t成功创建了User：#{found-users[0].name}"
  callback non-repeat-contacts-amount 


