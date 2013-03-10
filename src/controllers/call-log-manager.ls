/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

require! ['../models/Call-logs']

Call-log-manager =
  update-user-call-logs: !(user, call-logs, callback) ->
    last-call-log-time = new Date!.get-time!
    <-! Call-logs.update-user-call-log-and-related-statistic user, call-logs, last-call-log-time
    callback!

module.exports <<< Call-log-manager