/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['should', 'async', 
          '../../bin/models/User',
          '../../bin/servers-init'.init-mongo-client, 
          '../../bin/servers-init'.shutdown-mongo-client,
          '../../bin/util', '../test-helper']

[db, client] = [null null]

MULTIPLE-TIMES = 1000

REPEAT-RATE = 0.2

do
  (mongo-client, mongo-db) <-! init-mongo-client
  [db, client] := [mongo-db, mongo-client]
  <-! db.drop-collection 'users'
  <-! create-and-check-user 'zhangsan.json', '张三', MULTIPLE-TIMES, REPEAT-RATE
  <-! create-and-check-user 'lisi.json', '李四', MULTIPLE-TIMES, REPEAT-RATE
  <-! create-and-check-user 'zhaowu.json', '赵五', MULTIPLE-TIMES, REPEAT-RATE
  <-! shutdown-mongo-client client


!function create-and-check-user json-file-name, user-name, fake-contacts-amount, repeat-rate, callback
  console.log "\n\n*************** #{user-name} has #{fake-contacts-amount} contacts. ************************\n\n"
  start-time = new Date!
  <-! test-helper.create-and-check-user-with-mulitple-repeat-contacts db, json-file-name, user-name, fake-contacts-amount, repeat-rate
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-users[0].name.should.eql user-name
  end-time = new Date!
  console.log "\n\t 耗费时间 #{end-time - start-time}"
  callback! 

