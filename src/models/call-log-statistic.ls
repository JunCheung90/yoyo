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

  get-user-relative-statistic-year-sorted: !(user, callback) ->
    callback!

get-data-with-statistic-key = (user, call-logs-array-with-uid) ->
  time-quantums = ['TOTAL', 'YEAR', 'MONTH', 'DAY', 'HOUR']
  result-array = []
  md5-array = []
  for call-log-with-uid in call-logs-array-with-uid
    connected-user = get-connected-user user, call-log-with-uid
    for time-quantum in time-quantums
      time = get-start-time-and-end-time time-quantum, connected-user.time
      text = connected-user.from-uid + connected-user.to-uid + time-quantum + time.start-time + time.end-time
      md5 = crypto.create-hash('md5').update text .digest 'hex'

      index = _.index-of md5-array, md5

      if index == -1
        md5-array.push md5
        result-array.push init-data-with-statistic-key time-quantum, time, connected-user
      else
        result-array[index].call-log-datas.push {duration: connected-user.duration, time-quantum: connected-user.time-quantum, time: connected-user.time}
  result-array

create-or-update-statistic-nodes = !(call-log-datas-with-statistic-key-array, callback) ->
  (err) <-! async.for-each call-log-datas-with-statistic-key-array, !(data-with-statistic-key, next) ->
    (statistic) <-! get-or-init-statistic data-with-statistic-key.statistic-key
    statistic = update-statistic statistic, data-with-statistic-key
    <-! save-statistic statistic
    next!
  throw new Error err if err
  callback!

init-data-with-statistic-key = (time-quantum, time, connected-user) ->
  {
    statistic-key:
      time-quantum: time-quantum
      start-time: time.start-time
      end-time: time.end-time
      from-uid: connected-user.from-uid
      to-uid: connected-user.to-uid
    call-log-datas: 
      * duration: connected-user.duration
        time-quantum: connected-user.time-quantum
        time: connected-user.time
      ...      
  }

get-connected-user = (user, call-log-with-uid) ->
  if call-log-with-uid.time-quantum === 'OUT'
    from-uid = user.uid
    to-uid = call-log-with-uid.uid
  else
    from-uid = call-log-with-uid.uid
    to-uid = user.uid
  {from-uid: from-uid, to-uid: to-uid, time: call-log-with-uid.time, duration: call-log-with-uid.duration, time-quantum: call-log-with-uid.time-quantum}

get-start-time-and-end-time = (time-quantum, call-log-time) ->
  call-log-date = new Date!
  call-log-date.set-time call-log-time
  year = call-log-date.get-full-year!
  month = call-log-date.get-month!
  day = call-log-date.get-date!
  hour = call-log-date.get-hours!
  start-date = null
  end-date = null
  switch time-quantum
    case 'YEAR' then
      start-date = get-date year, 0, 1, 0, 0, 0
      end-date = get-date year, 11, 31, 23, 59, 59
    case 'MONTH' then
      start-date = get-date year, month, 1, 0, 0, 0     
      end-date = get-date year, month, (get-end-date year, month), 23, 59, 59
    case 'DAY' then
      start-date = get-date year, month, day, 0, 0, 0
      end-date = get-date year, month, day, 23, 59, 59
    case 'HOUR' then
      start-date = get-date year, month, day, hour, 0, 0
      end-date = get-date year, month, day, hour, 59, 59
    case 'TOTAL' then
      start-date = new Date!
      start-date.set-time 0
      end-date = start-date
      
  {start-time: start-date.get-time!, end-time: end-date.get-time!}

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

get-date = (year, month, day, hour, minute, second) ->
  date = new Date!
  date.set-full-year year
  date.set-month month
  date.set-date day
  date.set-hours hour
  date.set-minutes minute
  date.set-seconds second
  date.set-milliseconds 0
  date

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
  if call-log-data.time-quantum == 'MISS'
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