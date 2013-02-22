/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

require! [async, '../database', './Users', './Contacts']

_ = require 'underscore'

Call-logs =
  update-user-call-log: !(user, call-logs, callback) ->
    (call-logs-with-uid, last-call-log-time) <-! add-uid-to-each-call-log user, call-logs
    <-! update-user-call-logs-with-uid user, call-logs-with-uid, last-call-log-time
    <-! update-user-call-logs-statistic user, call-logs-with-uid, last-call-log-time
    callback!

add-uid-to-each-call-log = !(user, call-logs, callback)->
  (call-logs-with-uid, last-call-log-time) <-! async-add-uid-to-each-call-log user, call-logs
  callback call-logs-with-uid, last-call-log-time

async-add-uid-to-each-call-log = !(user, call-logs, callback) ->
  call-logs-with-uid = []
  last-call-log-time = null
  (err) <-! async.for-each call-logs, !(call-log, next) ->    
    contact = get-user-contact-with-phone-number user, call-log.phone-number
    console.log last-call-log-time
    if contact
      call-log.uid = contact.act-by-user
      #TODO: 判断通话记录是否已经被提交过，避免重复保存
      call-logs-with-uid ++= call-log
      last-call-log-time := call-log.time
      next!
    else
      (call-log-target-user) <-! Users.get-or-create-user-with-phone-number call-log.phone-number
      call-log.uid = call-log-target-user.uid      
      #TODO: 判断通话记录是否已经被提交过，避免重复保存
      call-logs-with-uid ++= call-log
      last-call-log-time := call-log.time
      next!
  throw new Error err if err
  callback call-logs-with-uid, last-call-log-time

get-user-contact-with-phone-number = (user, phone-number) ->
  for contact in user.contacts
    return contact if comparor-contact-with-phone-number contact, phone-number
  null

comparor-contact-with-phone-number = (contact, phone-number) ->
  phone-number in contact.phones

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

update-user-call-logs-statistic = !(user, call-logs-with-uid, last-call-log-time, callback) ->
  callback!

module.exports <<< CallLogs

