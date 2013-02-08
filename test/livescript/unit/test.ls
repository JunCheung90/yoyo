/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 'async', 
          '../../src/models/User',
          '../../src/servers-init'.init-mongo-client, 
          '../../src/servers-init'.shutdown-mongo-client,
          '../../src/util', '../test-helper']

fqh = require '../../src/fast-query-helper'

[db, client] = [null null]

multiple-times = 100 

repeat-rate = 0.2 

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'mongoDb版注册用户：识别用户，绑定用户（User）和联系人（Contact）', !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users' 
    <- fqh.init-communication-channels-maps db
    done! 

  can '创建User张三，张三有2个Contacts，作为0人的Contact。\n', !(done) ->
    <-! test-helper.create-and-check-user db, 'zhangsan.json', '张三'
    test-helper.check-user-contacts db, '张三', 2, 0, done

  can '创建User李四，李四有2个Contacts，作为1人的Contact。\n', !(done) ->
    <-! test-helper.create-and-check-user db, 'lisi.json', '李四'
    test-helper.check-user-contacts db, '李四', 2, 1, done 


  can '创建User赵五，赵五有3个Contacts，作为2人的Contacts。\n', !(done) ->
    <-! test-helper.create-and-check-user db, 'zhaowu.json', '赵五' 
    test-helper.check-user-contacts db, '赵五', 3, 2, done


  can '最新张三联系人情况，有2个Contacts，作为2人的Contacts。\n' !(done) ->
    test-helper.check-user-contacts db, '张三', 2, 2, done 

  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!

describe 'mongoDb版注册用户：简单合并联系人', !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users'
    <- fqh.init-communication-channels-maps db 
    done! 

  all-original-contacts = 3 # zhaowu.json中有3个联系人，2个不重复。
  non-repeat-original-contacts = 2 # zhaowu.json中有3个联系人，2个不重复。
 
  can '创建User赵五。赵五的联系人两个Contacts（张大三、张老三）合并为一。\n', !(done) ->
    <-! test-helper.create-and-check-user db, 'zhaowu.json', '赵五'
    (err, found-users) <-! db.users.find({'name': '赵五'}).to-array
    found-users.length.should.eql 1 
    <-! test-helper.are-contacts-merged-correct found-users[0].contacts, non-repeat-original-contacts
    (err, all-users) <-! db.users.find().to-array
    all-users.length.should.eql 3
    done!


  can '对多个重复联系人正确合并。\n', !(done) ->
    # 在初始数据的基础上，随机生成多个重复联系人，然后能够正确合并。
    <-! db.drop-collection 'users' # 不要重复创建赵五这个联系人。
    (non-repeat-contacts-amount) <-! test-helper.create-and-check-user-with-mulitple-repeat-contacts db, 'zhaowu.json', '赵五', multiple-times, repeat-rate
    (err, found-users) <-! db.users.find({'name': '赵五'}).to-array
    found-users.length.should.eql 1
    found-users[0].contacts.length.should.eql all-original-contacts + multiple-times
    <-! test-helper.are-contacts-merged-correct found-users[0].contacts, non-repeat-original-contacts + non-repeat-contacts-amount
    # (err, all-users) <-! db.users.find().to-array
    # all-users.length.should.eql 3
    done! 


  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!