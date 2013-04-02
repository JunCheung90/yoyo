/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

require! ['should', 
          '../../bin/models/call-logs'
          '../../bin/models/Users', '../../bin/db/database']
_ = require 'underscore'
_(global).extend require './test-merging-helper'

user-data = null
user = null

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '保存通话记录: ' !->
  do
    (done) <-! before
    <-! database.init-mongo-client
    <-! database.db.drop-collection 'users'
    <-! database.db.drop-collection 'call-logs'
    <-! database.db.drop-collection 'call-log-statistic'
    done!

  can "保存张三的通话记录，一共9个记录，并增加通话对象uid\n" !(done) ->    
    (zhangsan) <-! create-user-zhangsan
    <-! check-zhangsan-call-log zhangsan, 9
    done!

# describe '通话历史记录统计：', !->
#   do
#     (done) <-! before
#     <-! database.init-mongo-client
#     <-! database.db.drop-collection 'users'
#     <-! database.db.drop-collection 'call-logs'
#     <-! database.db.drop-collection 'call-log-statistic'
#     (zhangsan) <-! create-user-zhangsan
#     user = zhangsan
#     done!

#   can "张三通话次数统计，有4个打进，3个打出，2个未接\n" !(done) ->
#     check-total-call-log-count '', 4, 3, 2, done

#   can "张三通话时间统计，打进（206s），打出（649s）\n" !(done) ->
#     check-total-call-log-duration '', 206, 649, done

#   can "张三对李四通话次数统计，有3个打进，2个打出，1个未接\n" !(done) ->
#     check-total-call-log-count '李四', 3, 2, 1, done

#   can "张三对李四通话时间统计，打进106s，打出49s\n" !(done) ->
#     check-total-call-log-duration '李四', 106, 46, done

#   can "张三对赵五通话次数统计，有1个打进，1个打出，1个未接\n" !(done) ->
#     check-total-call-log-count '赵五', 1, 2, 1, done

#   can "张三对赵五通话时间统计，打进100s，打出600s\n" !(done) ->
#     check-total-call-log-duration '赵五', 100, 600, done

initial-test-environment = !(callback) ->
  (data) <- initial-environment
  user-data := data  
  callback!

check-zhangsan-call-log = !(user, call-log-count, callback) ->
  (err, zhangsan-call-logs) <-! database.db.call-logs.find-one({uid: user.uid})
  zhangsan-call-logs.call-logs.length.should.eql call-log-count
  for call-log in zhangsan-call-logs.call-logs
    call-log.should.have.property 'uid'
  callback!

create-user-zhangsan = !(callback) ->
  user-data = require '../test-data/zhangsan.json'
  (zhangsan) <-! Users.create-user-with-contacts user-data
  <-! call-logs.update-user-call-log-and-related-statistic zhangsan, user-data.calllogs, '2012-11-10 21:32:12'
  callback zhangsan

check-total-call-log-count = !(user-name, in-count, out-count, miss-count, callback) ->
  query-statement = {}
  if user-name is not ''
    query-statement <<< {name: user-name}
  (err, call-log-statistic-infos) <-! database.db.call-logs.find(query-statement).to-array
  call-log-statistic-infos.length.should.eql 1
  call-log-statistic-info = call-log-statistic-infos[0]

  call-log-statistic-info.in-count.should.eql in-count
  call-log-statistic-info.out-count.should.eql out-count
  call-log-statistic-info.miss-count.should.eql miss-count
  callback!

check-total-call-log-duration = !(user-name, in-count, out-count, miss-count, callback) ->
  query-statement = {}
  if user-name is not ''
    query-statement <<< {name: user-name}
  (err, call-log-statistic-infos) <-! database.db.call-logs.find(query-statement).to-array
  call-log-statistic-infos.length.should.eql 1
  call-log-statistic-info = call-log-statistic-infos[0]

  call-log-statistic-info.in-count.should.eql in-count
  call-log-statistic-info.out-count.should.eql out-count
  call-log-statistic-info.miss-count.should.eql miss-count
  callback!
