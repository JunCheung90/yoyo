/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

require! ['../config/config'.mongo,
          '../util'
          '../models/Call-logs'
          '../servers-init'.init-mongo-client, 
          '../servers-init'.shutdown-mongo-client
          '../database']

call-log-manager =
  update-user-call-logs: !(user, call-logs, callback) ->
    last-call-log-time = new Date!.get-time!
    <-! Call-logs.update-user-call-log-and-related-statistic user, call-logs, last-call-log-time
    callback!

module.exports <<< call-log-manager