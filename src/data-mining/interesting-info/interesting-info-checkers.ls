/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! [async, '../../db/database']
_ = require 'underscore'


Interesting-info-checkers =
  not-exist-node: (user, strategy, callback) ->
    contacts = user.contacts
    (err) <-! async.for-each contacts, !(contact, next) ->
      (nodes) <-! get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
      if nodes.length == 0
        user.interesting-infos ?= []
        user.interesting-infos ++= new-interesting-info 'never-contact', user, contact, nodes
      next!
    throw new Error err if err
    callback!

  field-largest: (user, strategy, callback) ->
    # contacts = user.contacts
    # contact-nodes = []
    # (err) <-! async.for-each contacts, !(contact, next) ->
    #   (nodes) <-! get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
    #   contact-nodes ++= nodes
    #   next!
    # throw new Error err if err

    # console.log contact-nodes

    # sorted-nodes = _.sort-by contact-nodes, !(node) ->
    #   node.statistic[strategy.fields[0]]

    # fit-count = Math.ceil contacts.length / 10 
    # fit-nodes = sorted-nodes.slice sorted-nodes.length - fit-count - 1

    # update-iis user, fit-nodes
    callback!

get-statistic-nodes = !(user, contact, roles, time-quantum, callback) ->
  (db) <-! database.get-db!
  params =
    $or: get-query-params user, contact, roles, time-quantum
  (err, nodes) <-! db.call-log-statistic.find(params).to-array!
  throw new Error err if err
  callback nodes

new-interesting-info = (type, user, contact, nodes) ->
  ii = {
    iiid: get-iiid user
    type: type 
    info: type
    data: 
      related-contact:
        name: contact.names[0]
        cid: contact.cid
      time-frame:
        start-time: 0
        end-time: 0
      calling-out-times: 0 
      calling-out-amount-time: 0 
      calling-in-times: 0
      calling-in-amount-time: 0
    created-time: new Date!.get-time!
  }
  fill-ii-data user, ii, nodes
  ii

get-iiid = (user) ->
  user.uid + '-ii-' + new Date!.get-time! + get-user-ii-seqno user

get-user-ii-seqno = (user) ->
  user.ii-seqno ?= 0
  user.ii-seqno++

fill-ii-data = (user, ii, nodes) ->
  for node in nodes
    if user.uid == nodes.from-uid
      ii.calling-out-times = node.statistic.count
      ii.calling-out-amount-time = node.statistic.duration
      ii.time-frame.start-time = node.start-time
      ii.time-frame.end-time = node.end-time
    else
      ii.calling-in-times = node.statistic.count
      ii.calling-in-amount-time = ndoe.statistic.duration
      ii.time-frame.start-time = node.start-time
      ii.time-frame.end-time = node.end-time    

get-query-params = (user, contact, roles, time-quantum) ->
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