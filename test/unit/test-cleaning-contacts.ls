/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 
          '../../bin/models/Users', '../../bin/models/User-Merger', '../../bin/util', '../../bin/database']
_ = require 'underscore'
_(global).extend require './test-merging-helper'

user-data = null


can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '清理无用的Contact：', !->
  describe '无通讯方式、不合法电子邮件', !->
    do
      (done) <-! before-each
      <-! initial-test-environment
      done!

    can '清除没有任何通讯方式（电话、电子邮件、IM、SN）的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and-a-contact-without-communication-channel
      zhangsan.contacts.should.have.length 1
      done! 
      
    can '清除只有不合法电子邮件的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["illegal-email"], "emails":["12d3"]}
      zhangsan.contacts ++= {"names": ["illegal-email-but-leagl-phone"], "emails":["12d3"], "phones": ['12345678901']}
      zhangsan.contacts.should.have.length 2
      done! 
    
  describe 'IM有关测试', !->
    do
      (done) <-! before-each
      <-! initial-test-environment
      done!

    can '清除只有不合法IM的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["illegal-IM"], "ims":[{"type": "", "account": ""}]}
      zhangsan.contacts ++= {"names": ["illegal-email-but-leagl-phone"], "ims":[{"type": "", "account": ""}], "phones": ['12345678901']}
      zhangsan.contacts.should.have.length 2
      done!  
      
    can '清除只有不合法IM（提供商，type）的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["illegal-IM"], "ims":[{"type": "illegal-provider", "account": "李四"}]}
      zhangsan.contacts ++= {"names": ["illegal-email-but-leagl-phone"], "ims":[{"type": "illegal-provider", "account": "李四"}], "phones": ['12345678901']}
      zhangsan.contacts.should.have.length 2
      should-have-contact-named zhangsan, 'illegal-email-but-leagl-phone'
      should-not-have-contact-named zhangsan, 'illegal-IM'
      done!  
      
    can '不会清除IM提供商（例如QQ）合法的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["legal-IM"], "ims":[{"type": "QQ", "account": "李四"}]}
      zhangsan.contacts.should.have.length 2
      should-have-contact-named zhangsan, 'legal-IM'
      done!  
    
  describe 'SN有关测试', !->
    do
      (done) <-! before-each
      <-! initial-test-environment
      done!

    can '清除只有不合法SN的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["illegal-sn"], "sns":[{"type": "", "account": ""}]}
      zhangsan.contacts ++= {"names": ["illegal-sn-but-leagl-phone"], "sns":[{"type": "", "account": ""}], "phones": ['12345678901']}
      zhangsan.contacts.should.have.length 2
      done! 

    can '清除只有不合法SN（提供商，type）的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["illegal-sn"], "sns":[{"type": "illegal-sn", "account": "李四"}]}
      zhangsan.contacts ++= {"names": ["illegal-sn-but-leagl-phone"], "sns":[{"type": "illegal-sn", "account": "李四"}], "phones": ['12345678901']}
      zhangsan.contacts.should.have.length 2
      done!

    can '不清除SN提供商合法的联系人。\n', !(done) ->
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["legal-sn", '李四'], "sns":[{"type": "SINA", "account": "李四"}]}
      zhangsan.contacts.should.have.length 2
      done!

  describe 'PHONE有关测试', !-> 
    do
      (done) <-! before-each
      <-! initial-test-environment
      done!

    can '清除只有字符不合法电话号码的联系人。\n', !(done) ->  #见/src/models/helpers/communication-channel-validator.ls的正则表达式
      (zhangsan) <- create-zhangsan-with-contacts-lidasi-and {"names": ["illegal-phone"], "phones":["qeerfa", "1w2"]}
      zhangsan.contacts.should.have.length 1
      done!    


  do
    (done) <-! after
    <-! database.shutdown-mongo-client
    done! 
  
# describe '清除合法联系人的不合法通讯方式：', !->
#   do
#     (done) <-! before-each
#     <-! initial-test-environment
#     done!

#   can '清除没有任何通讯方式（电话、电子邮件、IM、SN）的联系人。\n', !(done) ->
#     (zhangsan) <- create-zhangsan-with-contacts-lidasi-and-a-contact-without-communication-channel
#     zhangsan.contacts.should.have.length 1
#     done! 
    
     
#   do
#     (done) <-! after
#     <-! database.shutdown-mongo-client
#     done!


initial-test-environment = !(callback) ->
  (data) <- initial-environment
  user-data := data
  callback!

create-zhangsan-with-contacts-lidasi-and-a-contact-without-communication-channel = !(callback) ->
  create-zhangsan-with-contacts-lidasi-and {"names": ["contact-without-communication-channel"]}, callback

create-zhangsan-with-contacts-lidasi-and = !(contact, callback) ->
  ladasi = {"names": ["李小四"], "phones":["12345678901", "12345678903"]}
  user-data.contacts ++= [ladasi, contact]
  (user) <-! Users.create-user-with-contacts user-data
  callback user

should-one-user-merged-with-li-si = (li-da-si, li-xiao-si, li-si) ->
  [li-da-si.uid, li-xiao-si.uid].should.include li-si.uid