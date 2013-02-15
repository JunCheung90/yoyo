/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 
          '../../bin/models/Users', '../../bin/models/User-Merger', '../../bin/util', '../../bin/database',
          '../../bin/servers-init'.shutdown-mongo-client]
_ = require 'underscore'
_(global).extend require './test-merging-helper'

user-data = null


can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '清理无用的Contact：', !->
  do
    (done) <-! before-each
    <-! initial-test-environment
    done!

  can '清除没有任何通讯方式（电话、电子邮件、IM、SN）的联系人。\n', !(done) ->
    (zhangsan) <- create-zhangsan-with-contacts-lidasi-and-a-contact-without-communication-channel
    zhangsan.contacts.should.have.length 1
    done! 
    
  can '清除电子邮件不合法的联系人。\n', !(done) ->
    (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": "illegal-email", "emails":["12d3"]}
    zhangsan.contacts.should.have.length 1
    done! 
    
  do
    (done) <-! after
    <-! shutdown-mongo-client
    done!
  

initial-test-environment = !(callback) ->
  (data) <- initial-environment
  user-data := data
  callback!

create-zhangsan-with-contacts-lidasi-and-a-contact-without-communication-channel = !(callback) ->
  create-zhangsan-with-contacts-lidasi-and {"names": ["contact-without-communication-channel"]}, callback

create-zhangsan-with-contacts-lidasi-and = !(contact, callback) ->
  ladasi = {"names": ["李小四"], "phones":["123", "234"]}
  user-data.contacts ++= [ladasi, contact]
  (user) <-! Users.create-user-with-contacts user-data
  callback user

should-one-user-merged-with-li-si = (li-da-si, li-xiao-si, li-si) ->
  [li-da-si.uid, li-xiao-si.uid].should.include li-si.uid