/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 
          '../../bin/models/User',
          '../../bin/servers-init'.shutdown-mongo-client]
_ = require 'underscore'
_(global).extend require './test-merging-helper'

[db, client, user-data] = [null null null]

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 're-evaluate-user-pending-mergences测试：', !->
  do
    (done) <-! before-each
    <-! initial-test-environment
    done! 
  describe 'user信息更新之后，进行re-evaluation：', !->
    describe '建立user张三时，产生了pending-merge的contact user李大四、李小四。\
              新建（注册）用户李四（同时有李小四和李大四的电话），导致李大四、李小四user合并，它们的pending merge消失', !->
      can '两个user李四、李小四，李小四更新了电话号码（李四有的）之后。\n', !(done) ->
        (user) <- create-zhangsan-with-pending-merging-contacts-lisi-and-lixiaosi
        (li-da-si) <-! should-find-one-user-with-nickname '李大四'
        (li-xiao-si) <-! should-find-one-user-with-nickname '李小四'
        should-be-pending-merge-users-pair li-da-si, li-xiao-si
        
        (li-si) <-! create-li-si-with-phones-of-both-li-da-si-and-li-xiao-si
        (users) <-! should-find-all-users-amount-be 3
        (li-da-si) <-! should-find-one-user-with-nickname '李大四'
        (li-xiao-si) <-! should-find-one-user-with-nickname '李小四'
        # should-be-merged-pair li-da-si, li-xiao-si
        # should-has-not-pending-merges li-da-si
        # should-has-not-pending-merges li-xiao-si
        done! 
 
  do
    (done) <-! after-each 
    <-! shutdown-mongo-client client
    done!


initial-test-environment = !(callback) ->
  (mongo-db, mongo-client, data) <- initial-environment
  [db, client, user-data] := [mongo-db, mongo-client, data]
  callback!

create-zhangsan-with-pending-merging-contacts-lisi-and-lixiaosi = !(callback) ->
    contact-lisi1 = {"names": ["李小四"], "phones":["123", "234"]}
    contact-lisi2 = {"names": ["李大四"], "phones":["345"]}
    user-data.contacts ++= [contact-lisi1, contact-lisi2]
    (user) <-! User.create-user-with-contacts db, user-data
    callback user

create-li-si-with-phones-of-both-li-da-si-and-li-xiao-si = !(callback) ->
  (user) <-! User.create-user-with-contacts db, {name: '李四', phones: [{phone-number:'123'}, {phone-number:'345'}]}
  callback user