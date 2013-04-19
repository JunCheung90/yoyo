/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

<<<<<<< HEAD
require! [should, async, '../../bin/db/database']
require! Call-logs: '../../bin/models/call-logs', Users: '../../bin/models/users', \
        IIm: '../../bin/data-mining/interesting-info/interesting-info-mining', \
        qh: '../../bin/db/query-helper'
=======
require! ['should', 'async'
          '../../bin/models/call-logs'
          '../../bin/models/users', '../../bin/db/database'
          '../../bin/data-mining/interesting-info/interesting-info-mining']
qh = require '../../bin/db/query-helper'
>>>>>>> ef8218cb0344408e8ee145e870d7fa11bfd0f627
_ = require 'underscore'

Call-logs = call-logs
Users = users
user-data = null
user = null
lisi = null

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '有趣信息挖掘:', !->
  describe '识别通话对象，保存记录', !->
    do
      (done) <-! before
      <-! database.init-mongo-client
      <-! database.db.drop-collection 'users'
      <-! database.db.drop-collection 'call-logs'
      <-! database.db.drop-collection 'call-log-statistic'
      (zhangsan, call-logs) <-! create-user-zhangsan-with-contacts
      user := zhangsan   
      done!

    can "保存通话记录，能识别出已经是YoYo用户的通话对象\n" !(done) ->
      call-logs = require '../test-data/zhangsan-call-logs-data.json'
      (call-logs-with-uid) <-! update-user-call-logs user, call-logs
      <-! check-if-recognize-call-log-number-as-yoyo-user call-logs-with-uid
      done!

    can "还不是YoYo用户的对象，能够新建为YoYo用户\n" !(done) ->
      call-logs = require '../test-data/zhangsan-stranger-call-logs-data.json'
      <-! check-if-call-log-user-not-exist call-logs
      (call-logs-with-uid) <-! update-user-call-logs user, call-logs
      <-! check-if-recognize-as-new-user call-logs-with-uid
      done!

  describe '更新自身与通话对象之间的通话统计', !->
    do
      (done) <-! before
      (contacted-user) <-! get-user-with-phone "12345678"
      lisi := contacted-user
      done!
    can "李四呼叫张三通话次数统计，2013年，9次，373s，3未接\n" !(done) ->                                                          
         check-statistic lisi, user, "YEAR", 1356969600000, 9, 373, 3, done                                                           
                                                                                                                                    
    can "张三呼叫李四通话次数统计，2013年，5次，1250s，0未接\n" !(done) ->                                                         
      check-statistic user, lisi, "YEAR", 1356969600000, 5, 1250, 0, done         

    can "李四呼叫张三通话次数统计，2013年3月，3次，167s，1未接\n" !(done) ->
      check-statistic lisi, user, "MONTH", 1362067200000, 3, 167, 1, done

    can "张三呼叫李四通话次数统计，2013年3月，2次，601s，0未接\n" !(done) ->
      check-statistic user, lisi, "MONTH", 1362067200000, 2, 601, 0, done

    can "李四呼叫张三通话次数统计，2013年2月25，1次，15s，0未接\n" !(done) ->
      check-statistic lisi, user, "DAY", 1361721600000, 1, 15, 0, done

    can "张三呼叫李四通话次数统计，2013年2月25，1次，48s，0未接\n" !(done) ->
      check-statistic user, lisi, "DAY", 1361721600000, 1, 48, 0, done


  describe '有趣信息挖掘', !->
    do
      (done) <-! before
      <-! IIm.mining-user-interesting-info user
      done!

    can "有趣类型：most-call-out，李小四\n" !(done) ->
      check-iis user.interesting-infos, 'most-call-out', '李小四'
      done!

    can "有趣类型：most-call-in，李小四\n" !(done) ->
      check-iis user.interesting-infos, 'most-call-in', '李小四'
      done!

    can "有趣类型：never-contact，赵小五\n" !(done) ->      
      check-iis user.interesting-infos, 'never-contact', '赵小五'
      done!

    can "有趣类型：most-contact，李小四\n" !(done) ->
      check-iis user.interesting-infos, 'most-contact', '李小四'
      done!

    can "有趣类型：most-call-out-miss，李小四\n" !(done) ->
      check-iis user.interesting-infos, 'most-call-out-miss', '李小四'
      done!

    can "有趣类型：ost-call-in-miss，李小四\n" !(done) ->
      done!

    can "有趣类型：most-call-out-time，李小四\n" !(done) ->
      check-iis user.interesting-infos, 'most-call-out-time', '李小四'
      done!

    can "有趣类型：most-call-in-time，李小四\n" !(done) ->
      check-iis user.interesting-infos, 'most-call-in-time', '李小四'
      done!

    # can "有趣类型：largest-single-duration，李小四\n" !(done) ->
    #   done!


create-user-zhangsan-with-contacts = !(callback) ->
  user-data = require '../test-data/zhangsan.json'
  (zhangsan) <-! Users.create-user-with-contacts user-data 
  callback zhangsan

update-user-call-logs = !(user, call-logs,callback) ->
  (call-logs-with-uid) <-! Call-logs.update-user-call-log-and-related-statistic user, call-logs.call-logs, new Date!.get-time!
  callback call-logs-with-uid

check-if-recognize-call-log-number-as-yoyo-user = !(call-logs, callback) ->
  (err) <-! async.for-each call-logs, !(call-log, next) ->
    (user) <-! get-user-with-phone call-log.phone-number    
    user.should.have.property 'uid'
    call-log.should.have.property 'uid'
    user.uid.should.eql call-log.uid
    next!
  throw new Error err if err
  callback!

get-user-with-phone = !(phone-number, callback) ->
  (users) <-! qh.get-existed-users-on-phones [phone-number]  
  callback users[0]

check-if-call-log-user-not-exist = !(call-logs, callback) ->
  (err) <-! async.for-each call-logs, !(call-log, next) ->
    (users) <-! qh.get-existed-users-on-phones [call-log.phone-number]
    users.length.should.eql 0
    next!
  throw new Error err if err
  callback!

check-if-recognize-as-new-user = !(call-logs, callback) ->
  (err) <-! async.for-each call-logs, !(call-log, next) ->
    (users) <-! qh.get-existed-users-on-phones [call-log.phone-number]
    users.length.should.eql 1
    users[0].is-registered.should.eql false
    next!
  throw new Error err if err
  callback!

check-statistic = !(from-user, to-user, type, start-time, count, duration, miss-count, callback) ->
  (statistic) <-! query-statistic from-user, to-user, type, start-time
  statistic.data.count.should.eql count
  statistic.data.duration.should.eql duration
  statistic.data.miss-count.should.eql miss-count
  callback!

query-statistic = !(from-user, to-user, type, start-time, callback) ->
  query-statement = {}
  query-statement.from-uid = from-user.uid
  query-statement.to-uid = to-user.uid
  query-statement.time-quantum = type
  query-statement.start-time = start-time
  (db) <-! database.get-db!
  (err, statistic) <-! db.call-log-statistic.find-one query-statement
  callback statistic


check-iis = !(iis, type, name) ->
  property = {
    type: type 
  }
  result = _.where iis, property
  result.length.should.eql 1
  never-contacted-contact = result[0]
  never-contacted-contact.data.related-contact.name.should.eql name
