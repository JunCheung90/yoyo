/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! ['../../db/database']


Interesting-info-checkers =
  not-exist-node: (user, contact, roles, time-quantum, fields, callback) ->
    params =
      $or: get-from-to-user-id user, contact, roles, time-quantum
    (db) <-! database.get-db!
    (err, nodes) <-! db.call-log-statistic.find(params).to-array
    throw new Error err if err
    if nodes.length == 0
      callback true
    else
      callback false


  field-largest: (user, contact, roles, time-quantum, fields, callback) ->
    callback true


    

get-from-to-user-id = (user, contact, roles, time-quantum) ->
  results = []
  for role in roles
    switch role
    case 'fromUid'
      results.push {
        from-uid: user.uid
        to-uid: contact.act-by-user
        time-quantum: time-quantum
      }
    case 'toUid'
      results.push {
        from-uid: contact.act-by-user
        to-uid: user.uid
        time-quantum: time-quantum
      }
  results

module.exports <<< Interesting-info-checkers