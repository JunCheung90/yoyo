/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['should', 'async', 
          '../../src/models/User',
          '../../src/servers-init'.init-mongo-client, 
          '../../src/servers-init'.shutdown-mongo-client,
          '../../src/util', '../test-helper']

[db, client] = [null null]

MULTIPLE-TIMES = 1000
REPEAT-RATE = 0.2

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe "mongoDb版注册用户性能测试，联系人数量：#{MULTIPLE-TIMES}，重复率：#{REPEAT-RATE}", !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users'
    done! 

  can '创建User张三。\n', !(done) ->
    (non-repeat-contacts-amount) <-! test-helper.create-and-check-user-with-mulitple-repeat-contacts db, 'zhangsan.json', '张三', MULTIPLE-TIMES, REPEAT-RATE
    check-user-contacts '张三', non-repeat-contacts-amount + 2,  done

  can '创建User李四。\n', !(done) ->
    (non-repeat-contacts-amount) <-! test-helper.create-and-check-user-with-mulitple-repeat-contacts db, 'lisi.json', '李四', MULTIPLE-TIMES, REPEAT-RATE
    check-user-contacts '李四', non-repeat-contacts-amount + 2, done

  can '创建User赵五。\n', !(done) ->
    (non-repeat-contacts-amount) <-! test-helper.create-and-check-user-with-mulitple-repeat-contacts db, 'zhaowu.json', '赵五', MULTIPLE-TIMES, REPEAT-RATE
    check-user-contacts '赵五', non-repeat-contacts-amount + 2, done

  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!

!function check-user-contacts user-name, amount-of-has-contacts, callback
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-user = found-users[0]
  # found-user.contacts.length.should.eql amount-of-has-contacts
  callback!     

