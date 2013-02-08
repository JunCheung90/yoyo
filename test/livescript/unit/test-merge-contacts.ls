/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 'async', 
          '../../src/models/User',
          '../../src/servers-init'.init-mongo-client, 
          '../../src/servers-init'.shutdown-mongo-client,
          '../../src/util', '../test-helper']

fqh = require '../../src/fast-query-helper'

[db, client, user-data] = [null null null]

multiple-times = 100 

repeat-rate = 0.2 

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '联系人合并逻辑全面测试：', !->
  dump-user-name = '张三'   
  do
    (done) <-! before-each
    <-! initial-test-environment
    done! 
  describe '直接合并（direct-merging）逻辑测试', !->
    describe 'phones测试', !->
      can 'phones有一个相同（均非空）时，进行合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["123", "234"]}
        contact-lisi2 = {"names": ["李四"], "phones":["345", "234"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-one-contact-is-to found-user.contacts
        should-one-contact-is-from found-user.contacts
        merged-contact = get-the-merged-contact found-user.contacts
        merged-contact.names.should.eql ["李小四", "李四"]
        merged-contact.phones.should.eql ['123', '234', '345']
        done!

      can 'phones有一个为空时，不会合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["123", "234"]}
        contact-lisi2 = {"names": ["李四"], "phones":[]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'phones均不相同时，不会合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["123", "234"]}
        contact-lisi2 = {"names": ["李四"], "phones":["1", "4"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

    describe 'ims测试（sns逻辑相似，不单独测试）', !->
      can 'ims有一个相同（均非空）时，进行合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "飞信", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-one-contact-is-to found-user.contacts
        should-one-contact-is-from found-user.contacts
        merged-contact = get-the-merged-contact found-user.contacts
        merged-contact.names.should.eql ["李小四", "李四"]
        merged-contact.ims.should.eql [{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}, {"type": "飞信", "account": "lisi222"}]
        done!

      can 'ims有一个为空时，不会合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'ims均不相同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi222"}, {"type": "飞信", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'im中帐号（account）相同，类型（type）不同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "AOL", "account": "lisi111"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'im中类型（type）相同，帐号（account）不同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts db, user-data
        (found-user) <-! should-found-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!


  do
    (done) <-! after-each 
    <-! shutdown-mongo-client client
    done!


initial-test-environment = (callback) ->
  (mongo-client, mongo-db) <-! init-mongo-client
  [db, client] := [mongo-db, mongo-client]
  <-! db.drop-collection 'users'
  user-data := test-helper.load-user-data 'dump-user.json'
  callback!

should-found-one-user-named = !(username, callback) ->
  (err, found-users) <-! db.users.find({name: username}).to-array
  found-users.length.should.eql 1
  found-user = found-users[0]
  found-user.name.should.eql username
  callback found-user

should-one-contact-is-to = (contacts) ->
  should-amount-of-to-eql contacts, 1
  
should-one-contact-is-from = (contacts) ->
  should-amount-of-from-eql contacts, 1

should-amount-of-to-eql = (contacts, amount-of-to) ->
  tos = filter (.merged-to), contacts 
  tos.length.should.eql amount-of-to

should-amount-of-from-eql = (contacts, amount-of-from) ->
  froms = filter (.merged-from), contacts 
  froms.length.should.eql amount-of-from


get-the-merged-contact = (contacts) ->
  merged-contacts = filter (.merged-from), contacts 
  merged-contacts[0]

