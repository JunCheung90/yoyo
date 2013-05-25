
require! [async, '../../db/database']
Sh = require '../helpers/statistic-helper'
II = require '../interesting-info/interesting-info-checkers'
_ = require 'underscore'

recommend-contact-checkers = 
  recommend-users-by-recent-score: !(user, strategy, callback) ->
    contacts = user.contacts
    now-date = new Date!

    cid-to-contact-index = []
    for i til contacts.length
      cid-to-contact-index[contacts[i].cid] = i
      contacts[i].rank-scores = []

    recommend-nodes-in-hour = []
    (err) <-! async.for-each contacts, !(contact,next) ->
      (statistic-nodes) <-! II.get-statistic-nodes user, contact, strategy.roles, strategy.time-quantum
      recommend-nodes-in-hour.push conver-to-recommend-nodes contact, statistic-nodes, strategy.time-quantum, now-date
      next!
    throw new Err err if err

    for hour til 24
      #sort in descending order
      sorted-nodes = []
      sorted-nodes = _.sort-by recommend-nodes-in-hour, (node) ->
        node[hour][strategy.fields[0]] * -1
      
      for i til sorted-nodes.length
        node = sorted-nodes[i][hour]
        contacts[cid-to-contact-index[node.cid]].rank-scores[hour] = node[strategy.fields[0]]
        #remain for debug        
        #console.log "hour:"+hour+"cid:"+node.cid+"score:"+node.recommend-score

    callback!

conver-to-recommend-nodes = (contact, statistic-nodes, time-quantum, now-date) ->
  const range-size = 3
  recommend-nodes-in-hour = []
  
  shift-start-time-and-end-time = []
  for i til range-size
    shift-start-time-and-end-time.push Sh.get-now-shift-time now-date,time-quantum, -1 * i

  for now-hour til 24
    recommend-node = 
      cid: contact.cid
      recommend-score: 0
      recommend-time-quantum: time-quantum
      recommend-time-quantum-range: range-size
      update-time: now-date.get-time!

    recommend-total-for-add-score = 0
    for statistic in statistic-nodes
      recommend-total-for-add-score += statistic.data.duration
      for i til range-size
        if statistic.start-time = shift-start-time-and-end-time[i].start-time and statistic.end-time == shift-start-time-and-end-time[i].end-time
          data = statistic.data.distribution-in-hour[now-hour]
          recommend-node.recommend-score += ( data.count + data.miss-count * 3 + Math.log( data.duration / 60000 + 1) ) / (i+1)  
    
    recommend-node.recommend-score += Math.log( recommend-total-for-add-score / 60000 + 1) / Math.log( 10 )
    recommend-nodes-in-hour.push recommend-node

  recommend-nodes-in-hour


module.exports <<< recommend-contact-checkers
