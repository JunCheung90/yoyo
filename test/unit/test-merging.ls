/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [should, '../../bin/util', '../../bin/db/database']
require! Users: '../../bin/models/Users', User-Merger: '../../bin/mergence/User-Merger'
_ = require 'underscore'
_(global).extend require './test-merging-helper'

user-data = null


can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '联系人（Contact）与用户（User）合并逻辑全面测试：', !->
  describe 'Contact直接合并（direct-merging）逻辑测试', !->
    describe 'phones测试', !->
      do
        (done) <-! before-each
        <-! initial-test-environment
        done!
      
      can 'phones有一个相同（均非空）时，进行合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["12345678911", "22123456789"]}
        contact-lisi2 = {"names": ["李四"], "phones":["33123456789", "22123456789"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三' 
        found-user.contacts.length.should.eql 2
        should-one-contact-is-to found-user.contacts
        should-one-contact-is-from found-user.contacts
        merged-contact = get-the-merged-contact found-user.contacts
        merged-contact.names.should.eql ["李小四", "李四"]
        merged-contact.phones.should.eql ['12345678911', '22123456789', '33123456789']
        done!

      can 'phones有一个为空时，不会合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["12345678911", "22123456789"]}
        contact-lisi2 = {"names": ["李四"], "phones":[], "emails":["a@mail.com"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'phones均不相同时，不会合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["12345678911", "22123456789"]}
        contact-lisi2 = {"names": ["李四"], "phones":["33123456789", "44123456789"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

    describe 'ims测试（sns逻辑相似，不单独测试）', !->
      do
        (done) <-! before-each
        <-! initial-test-environment
        done! 
      can 'ims有一个相同（均非空）时，进行合并。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "飞信", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
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
        contact-lisi2 = {"names": ["李四"], "ims":[], "phones":["12345678911"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'ims均不相同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}, {"type": "AOL", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi222"}, {"type": "飞信", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'im中帐号（account）相同，类型（type）不同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "AOL", "account": "lisi111"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

      can 'im中类型（type）相同，帐号（account）不同时，不会合并。\n\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "ims":[{"type": "QQ", "account": "lisi111"}]}
        contact-lisi2 = {"names": ["李四"], "ims":[{"type": "QQ", "account": "lisi222"}]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (found-user) <-! should-find-one-user-named '张三'
        found-user.contacts.length.should.eql 2
        should-amount-of-to-eql found-user.contacts, 0
        should-amount-of-from-eql found-user.contacts, 0
        done!

  describe 'Contact推荐合并（pending-merging）逻辑测试', !->
    describe 'names测试', !->
      do
        (done) <-! before-each
        <-! initial-test-environment
        done! 
      can 'names有一个类似时（李小四 vs. 李大四），推荐合并联系人，并推荐合并对应联系人用户。\n', !(done) ->
        contact-lisi1 = {"names": ["李小四"], "phones":["12345678911", "22123456789"]}
        contact-lisi2 = {"names": ["李大四"], "phones":["33123456789"]}
        user-data.contacts ++= [contact-lisi1, contact-lisi2]

        (user) <-! Users.create-user-with-contacts user-data
        (users) <-! should-find-all-users-amount-be 3
        (zhangsan) <-! should-find-one-user-named '张三'
        zhangsan.contacts.should.have.length 2
        should-amount-of-contacts-has-pending-mergences-eql zhangsan.contacts, 2
        [source, distination] = get-pending-merging-contacts zhangsan.contacts
        should-be-a-pair-of-pending-merge-contacts source, distination

        (li-da-si) <-! should-find-a-user-with-nickname '李大四'
        (li-xiao-si) <-! should-find-a-user-with-nickname '李小四'
        should-be-a-pair-of-pending-merge-users li-da-si, li-xiao-si
        done!

  describe '新user合并到老user，会让老user is-updated = true。然后，可以（手动）再次评估用户的合并情况', !->
    '''
    建立user张三时，产生了pending-merge的contact user李大四、李小四。
    新建（注册）用户李四（同时有李小四和李大四的电话），此时，李四会直
    接merge到李大四或者李小四。并且merge的目的地会标志为is-updated。
    在运行了User.re-evaluated-mergences之后，李大四和李小四会合并，
    它们的pending merge消失。
    '''
    do
      (done) <-! before-each
      <-! initial-test-environment
      done! 
      
    can '两个user李四、李小四，李小四更新了电话号码（李四有的）之后。\n', !(done) ->
      (user) <- create-zhangsan-with-pending-merging-contacts-lidasi-and-lixiaosi
      (li-da-si) <-! should-find-a-user-with-nickname '李大四'
      (li-xiao-si) <-! should-find-a-user-with-nickname '李小四'
      
      (li-si) <-! create-li-si-with-phones-of-both-li-da-si-and-li-xiao-si
      (users) <-! should-find-all-users-amount-be 3
      (li-da-si) <-! should-find-a-user-with-nickname '李大四'
      (li-xiao-si) <-! should-find-a-user-with-nickname '李小四'
      should-one-user-merged-with-li-si li-da-si, li-xiao-si, li-si
      li-si.should.have.is-updated
      li-si.is-updated.should.be.true

      (users) <-! User-Merger.get-repeat-users li-si
      users.should.have.length 1
      User-Merger.direct-merge-users li-si, users[0]
      <-! util.update-multiple-docs 'users', [li-si, users[0]]
      (users) <-! should-find-not-merged-users 2
      (zhang-san) <-! should-find-a-user-named '张三'
      (li-si) <-! should-find-a-user-named '李四'
      li-si.should.have.nicknames
      li-si.nicknames.should.include '李大四', '李小四'
      li-si.pending-merges.should.eql []
      li-si.merged-from.should.have.length 1
      should.ok (li-si.merged-to is null)
      # li-si.merged-from
      # li-si.should.have.merged-to.with null
      done!  
  do
    (done) <-! after
    <-! database.shutdown-mongo-client
    done!
  

initial-test-environment = !(callback) ->
  (data) <- initial-environment
  user-data := data
  callback!

create-zhangsan-with-pending-merging-contacts-lidasi-and-lixiaosi = !(callback) ->
  contact-lisi1 = {"names": ["李小四"], "phones":["12345678911", "22123456789"]}
  contact-lisi2 = {"names": ["李大四"], "phones":["33123456789"]}
  user-data.contacts ++= [contact-lisi1, contact-lisi2]
  (user) <-! Users.create-user-with-contacts user-data
  callback user

create-li-si-with-phones-of-both-li-da-si-and-li-xiao-si = !(callback) ->
  (user) <-! Users.create-user-with-contacts {name: '李四', phones: [{phone-number:'12345678911'}, {phone-number:'33123456789'}]}
  callback user

should-one-user-merged-with-li-si = (li-da-si, li-xiao-si, li-si) ->
  [li-da-si.uid, li-xiao-si.uid].should.include li-si.uid