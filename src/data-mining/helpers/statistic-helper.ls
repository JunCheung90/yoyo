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

  get-pre-time: (time-quantum, call-log-time) ->
    switch time-quantum
      case 'YEAR' then
        call-log-time -= 24 * 60 * 60 * 1000 * get-pre-year-day-count call-log-time
      case 'MONTH' then
        call-log-time -= 24 * 60 * 60 * 1000 * get-pre-month-day-count call-log-time
      case 'DAY' then
        call-log-time -= 24 * 60 * 60 * 1000
      case 'HOUR' then
        call-log-time -=  60 * 60 * 1000
    @get-start-time-and-end-time time-quantum, call-log-time

  get-now-month-shift-time: (shift-num) ->
    shift-month-date = new Date!

    if shift-num < 0
        while shift-month-date + shift-num < 0
          shift-num += shift-month-date.get-month! + 1
          shift-month-date.set-full-year (shift-month-date.get-full-year! - 1)
          shift-month-date.set-month 11
    else
        while shift-month-date + shift-num > 11
          shift-num -= 12 - shift-month-date.get-month!
          shift-month-date.set-full-year (shift-month-date.get-full-year! + 1)
          shift-month-date.set-month 0

    shift-month-date.set-month (shift-month-date.get-month! + shift-num)

    @get-start-time-and-end-time 'MONTH', shift-month-date

  get-now-hour: ->
    date = new Date!
    date.getHours!

get-pre-year-day-count = (current-year-start-time) ->
  current-year-start-date = new Date current-year-start-time
  year = current-year-start-date.get-full-year!
  if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    return 366
  else
    return 365

get-pre-month-day-count = (current-month-start-time) ->
  current-year-start-date = new Date current-month-start-time
  month = current-year-start-date.get-month!
  year = current-year-start-date.get-full-year!
  get-end-date year, month


get-end-date = (year, month) ->
  if month == 1
    if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
      return 29
    else
      return 28
  else if month in [0, 2, 4, 6, 7, 9, 11]
    return 31
  else
    return 30

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
