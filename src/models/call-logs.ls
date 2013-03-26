/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
 
require! [async, '../database', '../util',
    './Users', './Contacts', './call-log-statistic', './interesting-info-mining']

Call-logs =
  update-user-call-log-and-related-statistic: !(user, call-logs, last-call-log-time, callback) ->
    (user-call-logs) <-! get-user-call-logs user
    if user-call-logs.last-call-log-time >= last-call-log-time
      callback!
    else
      (call-logs-with-uid) <-! add-uid-to-each-call-log user, call-logs    
      <-! update-user-call-logs-with-uid user-call-logs, call-logs-with-uid, last-call-log-time  
      <-! call-log-statistic.update-user-call-log-statistic user, call-logs-with-uid
      <-! interesting-info-mining.mining-user-interesting-info user
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

update-user-call-logs-with-uid = !(user-call-logs, call-logs-with-uid, last-call-log-time, callback) ->
  user-call-logs.last-call-log-time = last-call-log-time
  user-call-logs.call-logs = util.union user-call-logs.call-logs, call-logs-with-uid
  <-! save-user-call-log user-call-logs
  callback!

get-user-call-logs = !(user, callback) ->
  query-statement = {uid: user.uid}
  (db) <-! database.get-db
  (err, user-call-logs) <-! db.call-logs.find-one(query-statement)
  throw new Error err if err
  user-call-logs ?= {uid: user.uid, call-logs: [], last-call-log-time: 0}
  callback user-call-logs

save-user-call-log = !(user-call-logs, callback) ->
  (db) <-! database.get-db
  (err, user-call-logs) <-! db.call-logs.save user-call-logs
  throw new Error err if err
  callback!

module.exports <<< CallLogs