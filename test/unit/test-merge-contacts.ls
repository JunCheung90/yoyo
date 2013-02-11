/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 
          '../../bin/models/User', '../../bin/database',
          '../../bin/servers-init'.shutdown-mongo-client]
_ = require 'underscore'
_(global).extend require './test-merging-helper'

user-data = null


can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '联系人合并逻辑全面测试：', !->
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

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
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

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'phones均不相同时，不会合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["123", "234"]}
        contact-lisi2 = {"names": ["李四"], "phones":["1", "4"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

    describe 'ims测试（sns逻辑相似，不单独测试）', !->
      can 'ims有一个相同（均非空）时，进行合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "飞信", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
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

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'ims均不相同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi222"}, {"type": "飞信", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'im中帐号（account）相同，类型（type）不同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "AOL", "account": "lisi111"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'im中类型（type）相同，帐号（account）不同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

  describe '推荐合并（pending-merging）逻辑测试', !->
    describe 'names测试', !->
      can 'names有一个类似时（李小四 vs. 李四），推荐合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["123", "234"]}
        contact-lisi2 = {"names": ["李四"], "phones":["345"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! User.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-contacts-has-pending-mergences-eql found-user.contacts, 2
        [source, distination] = get-pending-merging-contacts found-user.contacts
        distination.pending-merges[0].pending-merge-from.should.eql source.cid
        source.pending-merges[0].pending-merge-to.should.eql distination.cid
        done!
 
  do
    (done) <-! after-each 
    <-! shutdown-mongo-client
    done!


initial-test-environment = !(callback) ->
  (data) <- initial-environment
  user-data := data
  callback!

