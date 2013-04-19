/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! [async, crypto, '../db/database']

Sh = require './helpers/statistic-helper'
_ = require 'underscore'

Call-log-statistic = 
  update-user-call-log-statistic: !(user, call-logs-array-with-uid, callback) ->
    call-log-datas-with-statistic-key-array = get-data-with-statistic-key user, call-logs-array-with-uid
    (statistics-for-modified) <- create-or-update-statistic-nodes call-log-datas-with-statistic-key-array
    callback!

  get-user-relative-statistic-year-sorted: !(user, callback) ->
    callback!

get-data-with-statistic-key = (user, call-logs-array-with-uid) ->
  time-quantums = ['TOTAL', 'YEAR', 'MONTH', 'DAY', 'HOUR']
  result-array = []
  md5-array = []
  for call-log-with-uid in call-logs-array-with-uid
    contacted-user = get-contacted-user user, call-log-with-uid
    for time-quantum in time-quantums
      time = Sh.get-start-time-and-end-time time-quantum, contacted-user.time
      text = contacted-user.from-uid + contacted-user.to-uid + time-quantum + time.start-time + time.end-time
      md5 = crypto.create-hash('md5').update text .digest 'hex'

      index = _.index-of md5-array, md5

      if index == -1
        md5-array.push md5
        result-array.push init-data-with-statistic-key time-quantum, time, contacted-user
      else
        result-array[index].call-log-datas.push {duration: contacted-user.duration, type: contacted-user.type, time: contacted-user.time}
  result-array

create-or-update-statistic-nodes = !(call-log-datas-with-statistic-key-array, callback) ->
  (err) <-! async.for-each call-log-datas-with-statistic-key-array, !(data-with-statistic-key, next) ->
    (statistic) <-! get-or-init-statistic data-with-statistic-key.statistic-key
    statistic = update-statistic statistic, data-with-statistic-key
    <-! save-statistic statistic
    next!
  throw new Error err if err
  callback!

init-data-with-statistic-key = (time-quantum, time, contacted-user) ->
  {
    statistic-key:
      time-quantum: time-quantum
      start-time: time.start-time
      end-time: time.end-time
      from-uid: contacted-user.from-uid
      to-uid: contacted-user.to-uid
    call-log-datas: 
      * duration: contacted-user.duration
        type: contacted-user.type
        time: contacted-user.time
      ...      
  }

get-contacted-user = (user, call-log-with-uid) ->
  if call-log-with-uid.type === 'OUT'
    from-uid = user.uid
    to-uid = call-log-with-uid.uid
  else
    from-uid = call-log-with-uid.uid
    to-uid = user.uid
  {from-uid: from-uid, to-uid: to-uid, time: call-log-with-uid.time, duration: call-log-with-uid.duration, type: call-log-with-uid.type}

get-or-init-statistic = !(statistic-key, callback) ->
  (db) <-! database.get-db
  (err, statistic) <-! db.call-log-statistic.find-one statistic-key
  throw new Error err if err

  if !statistic
    statistic = _.clone statistic-key
    statistic.data = init-statistic-data!
  callback statistic

init-statistic-data = ->
  {
    count: 0
    duration: 0
    miss-count: 0
    distribution-in-hour:
      init-distribution-in-hour!
  }

init-distribution-in-hour = ->
  distribution-in-hour = []
  for i from 0 to 23
    distribution-in-hour.push {
      count: 0
      duration: 0
      miss-count: 0
      hour: i
    }
  distribution-in-hour

update-statistic = (statistic, data-with-statistic-key) ->
  for call-log-data in data-with-statistic-key.call-log-datas
    statistic.data = update-statistic-data statistic.data, call-log-data

    if data-with-statistic-key.statistic-key.time-quantum != 'HOUR'
      hour = get-hour-by-time call-log-data.time
      statistic.data.distribution-in-hour[hour] = update-statistic-data statistic.data.distribution-in-hour[hour], call-log-data    
  statistic

update-statistic-data = (statistic-data, call-log-data) ->
  statistic-data.count++
  statistic-data.duration += call-log-data.duration
  if call-log-data.type == 'MISS'
    statistic-data.miss-count++
  statistic-data

get-hour-by-time = (time) ->
  date = new Date!
  date.set-time time
  date.get-hours!

save-statistic = !(statistic, callback) ->
  (db) <-! database.get-db
  (err) <-! db.call-log-statistic.save statistic
  throw new Error err if err
  callback!

module.exports <<< Call-log-statistic