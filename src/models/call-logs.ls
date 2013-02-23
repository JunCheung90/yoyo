/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
 
require! [async, '../database', './Users', './Contacts']

_ = require 'underscore'

Call-logs =
  update-user-call-log: !(user, call-logs, last-call-log-time, callback) ->
    (call-logs-with-uid) <-! add-uid-to-each-call-log user, call-logs    
    <-! update-user-call-logs-with-uid user, call-logs-with-uid, last-call-log-time    
    <-! update-statistic user, call-logs-with-uid
    callback!

add-uid-to-each-call-log = !(user, call-logs, callback)->
  (call-logs-with-uid) <-! async-add-uid-to-each-call-log user, call-logs
  callback call-logs-with-uid

async-add-uid-to-each-call-log = !(user, call-logs, callback) ->
  call-logs-with-uid = []
  (err) <-! async.for-each call-logs, !(call-log, next) ->    
    contact = get-user-contact-with-phone-number user, call-log.phone-number
    if contact
      call-log.uid = contact.act-by-user
      #TODO: 判断通话记录是否已经被提交过，避免重复保存
      call-logs-with-uid ++= call-log
      next!
    else
      (call-log-target-user) <-! Users.get-or-create-user-with-phone-number call-log.phone-number
      call-log.uid = call-log-target-user.uid      
      #TODO: 判断通话记录是否已经被提交过，避免重复保存
      call-logs-with-uid ++= call-log
      next!
  throw new Error err if err
  callback call-logs-with-uid

get-user-contact-with-phone-number = (user, phone-number) ->
  for contact in user.contacts
    return contact if phone-number in contact.phones
  null

update-user-call-logs-with-uid = !(user, call-logs-with-uid, last-call-log-time, callback) ->
  (user-call-logs) <-! get-user-call-logs user
  user-call-logs ?= {uid: user.uid, call-logs: []}
  user-call-logs.last-call-log-time = last-call-log-time
  user-call-logs.call-logs = _.union user-call-logs.call-logs, call-logs-with-uid
  <-! save-user-call-log user-call-logs
  callback!

get-user-call-logs = !(user, callback) ->
  query-statement = {uid: user.uid}
  db = database.get-db!
  (err, user-call-logs) <-! db.call-logs.find-one(query-statement)
  throw new Error err if err
  callback user-call-logs

save-user-call-log = !(user-call-logs, callback) ->
  db = database.get-db!
  (err, user-call-logs) <-! db.call-logs.save user-call-logs
  throw new Error err if err
  callback!

update-statistic = !(user, call-logs-with-uid, callback) ->
  connected-users = get-connected-users user, call-logs-with-uid
  (call-log-statistics) <-! get-or-init-call-log-statistics connected-users
  call-log-statistics = update-statistic-by-each-call-log call-log-statistics, connected-users
  <-! save-call-log-statistics call-log-statistics
  callback!

get-connected-users = (user, call-logs-with-uid) ->
  connected-users = []
  for call-log-with-uid in call-logs-with-uid
    new-connected-user = init-connected-user-in-fomat user, call-log-with-uid
    connected-users := add-element-without-duplicate connected-users, new-connected-user
  connected-users

init-connected-user-in-fomat = (user, call-log) ->
  if call-log.type === 'OUT'
    from-uid = user.uid
    to-uid = call-log.uid
  else
    from-uid = call-log.uid
    to-uid = user.uid
  {from-uid: from-uid, to-uid: to-uid, times: [call-log.time], durations: [call-log.duration], types: [call-log.type]}

add-element-without-duplicate = (connected-users, new-connected-user) ->
  for connected-user, i in connected-users
    if connected-user.from-uid === new-connected-user.from-uid && connected-user.to-uid === new-connected-user.to-uid
      connected-users[i].times ++= new-connected-user.times
      connected-users[i].durations ++= new-connected-user.durations
      connected-users[i].types ++= new-connected-user.types
      return connected-users
  connected-users ++= new-connected-user
  connected-users

get-or-init-call-log-statistics = !(connected-users, callback) ->
  call-log-statistics = []
  (err) <-! async.for-each connected-users, !(connected-user, next) ->
    (err, call-log-statistic) <-! database.db.call-log-statistic.find-one({from-uid: connected-user.from-uid, to-uid: connected-user.to-uid})
    call-log-statistic ?= {from-uid: connected-user.from-uid, to-uid: connected-user.to-uid, statistic: {count: 0, miss-count: 0, duration: 0}, child-node: []}
    call-log-statistics ++= call-log-statistic
    next!
  throw new Error err if err
  callback call-log-statistics

update-statistic-by-each-call-log = (call-log-statistics, connected-users) ->
  for connected-user, i in connected-users
    #TODO: 目前只统计两个user之间总数据，下一步需要增加统计各时间节点的数据，完善‘统计树’
    call-log-statistics[i].statistic.count += connected-user.times.length
    for duration, i in connected-user.durations
      call-log-statistics[i].statistic.duration += duration
      if connected-user.types[i] === 'MISS'
        call-log-statistics[i].statistic.miss-count += 1

  call-log-statistics

save-call-log-statistics = !(call-log-statistics, callback) ->
  (err) <-! async.for-each call-log-statistics, !(call-log-statistic, next) ->
    (err) <-! database.db.call-log-statistic.save call-log-statistic
    throw new Error err if err
    next! 
  throw new Error err if err
  callback!

module.exports <<< CallLogs