/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! [async, '../../db/database']
_ = require 'underscore'


Interesting-info-checkers =
  not-exist-node: (user, roles, time-quantum, fields, callback) ->
    contacts = user.contacts
    (err) <-! async.for-each contacts, !(contact, next) ->
      (nodes) <-! get-statistic-nodes user, contact, roles, time-quantum
      if nodes.length == 0
        user.interesting-infos ?= []
        user.interesting-infos ++= new-interesting-info 'never-contact', user, contact, nodes
      next!
    throw new Error err if err
    callback!

  field-largest: (user, roles, time-quantum, fields, callback) ->
    callback true

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
    info: '#{data.related-contact.name}坑电话费啊, #{data.time-frame}我竟然打了#{calling-out-times}电话给他，\
          说了#{data.calling-out-amount-time}，至少花了我#{data.fee}。这笔帐不能不算！<a href=#{data.related-contact.cid}>#{data.related-contact.name}</a>\
          还我小钱钱来！'
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

interesting-info-creator = (user, nodes, ii-type) ->
  {
    iiid: user.uid + '-ii-' + new Date!.get-time!
    type: ii-type
    info: null
    data:
      time-frame:
        quantum: null
        start-time: null
        end-time: null
      in-count: 0
      out-count: 0
      miss-count: 0
      in-duration: 0
      out-duration: 0
  }
    

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