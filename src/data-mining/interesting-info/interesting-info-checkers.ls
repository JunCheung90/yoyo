/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! [async, '../../db/database']
Sh = require '../helpers/statistic-helper'
_ = require 'underscore'


Interesting-info-checkers =
  not-exist-node: (user, strategy, callback) ->
    contacts = user.contacts
    (err) <-! async.for-each contacts, !(contact, next) ->
      (statistic-nodes) <-! get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
      if statistic-nodes.length == 0
        user.interesting-infos ?= []
        user.interesting-infos.push new-interesting-info strategy.type, user, contact, statistic-nodes
      next!
    throw new Error err if err
    callback!

  field-largest: (user, strategy, callback) ->
    contacts = user.contacts
    contact-nodes = []
    (err) <-! async.for-each contacts, !(contact, next) ->
      (statistic-nodes) <-! get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
      if statistic-nodes.length > 0
        contact-nodes.push conver-to-contact-nodes contact, statistic-nodes 
      next!
    throw new Error err if err

    sorted-nodes = _.sort-by contact-nodes, (node) ->
      node.total-count.[strategy.fields[0]]

    fit-count = Math.ceil contacts.length / 10 
    fit-nodes = sorted-nodes.slice sorted-nodes.length - fit-count - 1

    update-iis user, strategy, fit-nodes
    callback!

update-iis = !(user, strategy, contact-nodes) ->
  for contact-node in contact-nodes
    ii = new-interesting-info strategy.type, user, contact-node.contact, contact-node.statistic-nodes
    user.interesting-infos ?= [] 
    user.interesting-infos.push ii

conver-to-contact-nodes = (contact, statistic-nodes) ->
  contact-node = 
    contact: contact
    statistic-nodes: statistic-nodes
    total-count:
      count: 0
      duration: 0
      miss-count:0
  
  for statistic in statistic-nodes
    contact-node.total-count.count += statistic.data.count
    contact-node.total-count.duration += statistic.data.duration
    contact-node.total-count.miss-count += statistic.data.miss-count

  contact-node

get-statistic-nodes = !(user, contact, roles, time-quantum, callback) ->
  (db) <-! database.get-db!
  params =
    $or: get-query-params user, contact, roles, time-quantum
  (err, statistic-nodes) <-! db.call-log-statistic.find(params).to-array!
  throw new Error err if err
  callback statistic-nodes

new-interesting-info = (type, user, contact, statistic-nodes) ->
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
    created-time: new Date!.get-time!
  }
  fill-ii-data user, ii, statistic-nodes
  ii

get-iiid = (user) ->
  user.uid + '-ii-' + new Date!.get-time! + get-user-ii-seqno user

get-user-ii-seqno = (user) ->
  user.ii-seqno ?= 0
  user.ii-seqno++

fill-ii-data = !(user, ii, statistic-nodes) ->
  for node in statistic-nodes
    if user.uid == node.from-uid
      ii.data.calling-out-times = node.data.count
      ii.data.calling-out-amount-time = node.data.duration
      ii.data.calling-out-miss-times = node.data.miss-count
      ii.data.time-frame.start-time = node.start-time
      ii.data.time-frame.end-time = node.end-time
    else
      ii.data.calling-in-times = node.data.count
      ii.data.calling-in-amount-time = node.data.duration
      ii.data.calling-in-miss-times = node.data.miss-count
      ii.data.time-frame.start-time = node.start-time
      ii.data.time-frame.end-time = node.end-time    

get-query-params = (user, contact, roles, time-quantum) ->
  results = []
  time = Sh.get-start-time-and-end-time time-quantum, new Date!.get-time!
  for role in roles
    switch role
    case 'fromUid'
      results.push {
        from-uid: user.uid
        to-uid: contact.act-by-user
        time-quantum: time-quantum
        start-time: time.start-time
        end-time: time.end-time
      }
    case 'toUid'
      results.push {
        from-uid: contact.act-by-user
        to-uid: user.uid
        time-quantum: time-quantum
        start-time: time.start-time
        end-time: time.end-time
      }
  results
module.exports <<< Interesting-info-checkers