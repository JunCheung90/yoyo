/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! [async, crypto, '../database']

_ = require 'underscore'

Call-log-statistic = 
  update-user-call-log-statistic: !(user, call-logs-array-with-uid, callback) ->
    call-log-datas-with-statistic-key-array = get-data-with-statistic-key user, call-logs-array-with-uid
    (statistics-for-modified) <- create-or-update-statistic-nodes call-log-datas-with-statistic-key-array
    callback!

get-data-with-statistic-key = (user, call-logs-array-with-uid) ->
  node-types = ['YEAR', 'MONTH', 'DAY', 'HOUR']
  result-array = []
  md5-array = []
  for call-log-with-uid in call-logs-array-with-uid
    connected-user = get-connected-user user, call-log-with-uid
    for node-type in node-types
      time = get-start-time-and-end-time node-type, connected-user.time
      text = connected-user.from-uid + connected-user.to-uid + node-type + time.start-time + time.end-time
      md5 = crypto.create-hash('md5').update text .digest 'hex'

      index = _.index-of md5-array, md5

      if index == -1
        md5-array.push md5
        result-array.push init-data-with-statistic-key node-type, time, connected-user
      else
        result-array[index].call-log-datas.push {duration: connected-user.duration, type: connected-user.type, time: connected-user.time}
  result-array

create-or-update-statistic-nodes = !(call-log-datas-with-statistic-key-array, callback) ->
  (err) <-! async.for-each call-log-datas-with-statistic-key-array, !(data-with-statistic-key, next) ->
    (statistic) <-! get-or-init-statistic data-with-statistic-key.statistic-key
    statistic = update-statistic statistic, data-with-statistic-key
    <-! save-statistic statistic
    next!
  throw new Error err if err
  callback!

init-data-with-statistic-key = (node-type, time, connected-user) ->
  {
    statistic-key:
      type: node-type
      start-time: time.start-time
      end-time: time.end-time
      from-uid: connected-user.from-uid
      to-uid: connected-user.to-uid
    call-log-datas: 
      * duration: connected-user.duration
        type: connected-user.type
        time: connected-user.time
      ...      
  }

get-connected-user = (user, call-log-with-uid) ->
  if call-log-with-uid.type === 'OUT'
    from-uid = user.uid
    to-uid = call-log-with-uid.uid
  else
    from-uid = call-log-with-uid.uid
    to-uid = user.uid
  {from-uid: from-uid, to-uid: to-uid, time: call-log-with-uid.time, duration: call-log-with-uid.duration, type: call-log-with-uid.type}

get-start-time-and-end-time = (node-type, call-log-time) ->
  time-split = call-log-time / ' '
  time-strings = time-split[0] / '-'
  time-strings ++= time-split[1] / ':'
  start-time = null
  end-time = null
  switch node-type
    case 'YEAR' then
      start-time = time-strings[0] + '-01-01 00:00:00'
      end-time = time-strings[0] + '-12-31 23:59:59'
    case 'MONTH' then
      start-time = time-strings[0] + '-' + time-strings[1] + '-01 00:00:00'
      end-time = time-strings[0] + '-' + time-strings[1] + '-' + get-end-date! + ' 23:59:59'
    case 'DAY' then
      start-time = time-strings[0] + '-' + time-strings[1] + '-' + time-strings[2] + ' 00:00:00'
      end-time = time-strings[0] + '-' + time-strings[1] + '-' + time-strings[2] + ' 23:59:59'
    case 'HOUR' then
      start-time = time-strings[0] + '-' + time-strings[1] + '-' + time-strings[2] + ' ' + time-strings[3] + ':00:00'
      end-time = time-strings[0] + '-' + time-strings[1] + '-' + time-strings[2] + ' ' + time-strings[3] + ':59:59'
  {start-time: start-time, end-time: end-time}

get-end-date = (year, month) ->
  if month == '02'
    year = parse-int year
    if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
      return '29'
    else
      return '28'
  else if month in ['01', '03', '05', '07', '08', '10', '12']
    return '31'
  else
    return '30'

get-or-init-statistic = !(statistic-key, callback) ->
  (err, statistic) <-! database.db.call-log-statistic.find-one statistic-key
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

    if data-with-statistic-key.statistic-key.type != 'HOUR'
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
  time-strings = time / ' '
  time-strings = time-strings[1] / ':'
  hour = parse-int time-strings[0]

save-statistic = !(statistic, callback) ->
  (err) <-! database.db.call-log-statistic.save statistic
  throw new Error err if err
  callback!

module.exports <<< Call-log-statistic