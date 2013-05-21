/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! [async, '../../db/database']
Sh = require '../helpers/statistic-helper'
_ = require 'underscore'


Interesting-info-checkers =
  not-exist-node: !(user, strategy, callback) ->
    contacts = user.contacts
    (err) <-! async.for-each contacts, !(contact, next) ->
      (statistic-nodes) <-! get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
      if statistic-nodes.length == 0
        user.interesting-infos ?= []
        user.interesting-infos.push new-interesting-info strategy.type, user, contact, statistic-nodes
      next!
    throw new Error err if err
    callback!

  field-largest: !(user, strategy, callback) ->
    contacts = user.contacts
    contact-nodes = []
    (err) <-! async.for-each contacts, !(contact, next) ->
      (statistic-nodes) <-! get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
      if statistic-nodes.length > 0
        contact-nodes.push conver-to-contact-nodes contact, statistic-nodes, get-now-hour!
      next!
    throw new Error err if err

    sorted-nodes = []
    if strategy.type == 'recommended-users' or strategy.type == 'largest-month-duration'
        sorted-nodes = _.sort-by contact-nodes, (node) ->
          node[strategy.fields[0]]
    else
        sorted-nodes = _.sort-by contact-nodes, (node) ->
          node.total-count.[strategy.fields[0]]

    rate = 0.1
    fit-start = Math.floor sorted-nodes.length * (1 - rate)
    fit-nodes = sorted-nodes.slice fit-start

    update-iis user, strategy, fit-nodes
    callback!


  average-largest: !(user, strategy, callback) ->
    contacts = user.contacts
    contact-nodes = []
    (err) <-! async.for-each contacts, !(contact, next) ->
      (statistic-nodes) <-! get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
      contact-node = conver-to-contact-nodes contact, statistic-nodes, get-now-hour!
      if statistic-nodes.length > 0 && contact-node.total-count.[strategy.fields[1]] > 0
        contact-nodes.push contact-node
      next!
    throw new Error err if err          
    
    sorted-nodes = _.sort-by contact-nodes, (node) ->
      node.total-count.[strategy.fields[0]] / node.total-count.[strategy.fields[1]]

    rate = 0.1
    fit-start = Math.floor sorted-nodes.length * (1 - rate)
    fit-nodes = sorted-nodes.slice fit-start

    update-iis user, strategy, fit-nodes
    callback!

update-iis = !(user, strategy, contact-nodes) ->
  for contact-node in contact-nodes
    ii = new-interesting-info strategy.type, user, contact-node.contact, contact-node.statistic-nodes
    user.interesting-infos ?= [] 
    user.interesting-infos.push ii

conver-to-contact-nodes = (contact, statistic-nodes, hour) ->
  contact-node = 
    contact: contact
    statistic-nodes: statistic-nodes
    now-month-max-duration: 0
    now-hour-score: 0
    total-count:
      count: 0
      duration: 0
      miss-count:0
  
  now-month-start-time-and-end-time = Sh.get-start-time-and-end-time 'MONTH', new Date!

  for statistic in statistic-nodes
    contact-node.total-count.count += statistic.data.count
    contact-node.total-count.duration += statistic.data.duration
    contact-node.total-count.miss-count += statistic.data.miss-count
    #update now-month-max-duration
    if statistic.start-time == now-month-start-time-and-end-time.start-time && statistic.end-time == now-month-start-time-and-end-time.end-time
      now-month-max-duration = now-month-max-duration >? statistic.data.duration
    #update now-hour-score
    contact-node.now-hour-score += statistic.data.count * 60
    if hour < 24 && hour >= 0
       dis-data = statistic.data.distribution-in-hour[hour]
       contact-node.now-hour-score += dis-data.count * 300 + dis-data.duration

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
  user.uid + '-ii-' + new Date!.get-time! + get-user-iis-seq user

get-user-iis-seq = (user) ->
  user.iis-seq ?= 0
  user.iis-seq++

fill-ii-data = !(user, ii, statistic-nodes) ->
  for node in statistic-nodes
    if user.uid == node.from-uid
      ii.data.calling-out-times ?= 0
      ii.data.calling-out-amount-time ?= 0
      ii.data.calling-out-miss-times ?= 0
      ii.data.calling-out-times += node.data.count
      ii.data.calling-out-amount-time += node.data.duration
      ii.data.calling-out-miss-times += node.data.miss-count
      ii.data.time-frame.start-time = node.start-time if ii.data.time-frame.start-time == 0 || ii.data.time-frame.start-time > node.start-time
      ii.data.time-frame.end-time = node.end-time if ii.data.time-frame.end-time < node.end-time
    else
      ii.data.calling-in-times ?= 0
      ii.data.calling-in-amount-time ?= 0
      ii.data.calling-in-miss-times ?= 0
      ii.data.calling-in-times += node.data.count
      ii.data.calling-in-amount-time += node.data.duration
      ii.data.calling-in-miss-times += node.data.miss-count
      ii.data.time-frame.start-time = node.start-time if ii.data.time-frame.start-time == 0 || ii.data.time-frame.start-time > node.start-time
      ii.data.time-frame.end-time = node.end-time if ii.data.time-frame.end-time < node.end-time   

get-query-params = (user, contact, roles, time-quantum) ->
  results = []
  time = Sh.get-start-time-and-end-time time-quantum, new Date!.get-time!
  pre-time = Sh.get-pre-time time-quantum, new Date!.get-time!
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
      if pre-time
        results.push {
          from-uid: user.uid
          to-uid: contact.act-by-user
          time-quantum: time-quantum
          start-time: pre-time.start-time
          end-time: pre-time.end-time
        }
    case 'toUid'
      results.push {
        from-uid: contact.act-by-user
        to-uid: user.uid
        time-quantum: time-quantum
        start-time: time.start-time
        end-time: time.end-time
      }
      if pre-time
        results.push {
          from-uid: contact.act-by-user
          to-uid: user.uid
          time-quantum: time-quantum
          start-time: pre-time.start-time
          end-time: pre-time.end-time
        }
  results

get-now-hour = ->
  date = new Date!
  date.getHours!
module.exports <<< Interesting-info-checkers
