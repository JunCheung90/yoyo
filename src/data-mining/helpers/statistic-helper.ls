/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

Statistic-helper = 
  get-start-time-and-end-time: (time-quantum, call-log-time) ->
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

module.exports <<< Statistic-helper