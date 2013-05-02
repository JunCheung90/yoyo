/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

require! Call-logs: '../models/call-logs', Users: '../models/users', IIm: '../data-mining/interesting-info/interesting-info-mining'
require! ['../util']

Call-log-manager =
  synchronize-user-call-logs: !(synchronize-data, callback) ->
    self = this
    (user) <-! Users.get-user-by-uid synchronize-data.uid
    <-! self.update-user-call-logs user, synchronize-data.call-logs, synchronize-data.last-call-log-time
    callback {result-code: 0}

  update-user-call-logs: !(user, call-logs, last-call-log-time, callback) ->
    last-call-log-time ?= new Date!.get-time!
    <-! Call-logs.update-user-call-log-and-related-statistic user, call-logs, last-call-log-time
    <-! IIm.mining-user-interesting-info user
    callback!

module.exports <<< Call-log-manager