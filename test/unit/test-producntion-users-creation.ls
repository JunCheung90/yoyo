/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 'YoYo-Mock', 'async'
          '../../bin/models/Users', '../../bin/models/User-Merger', '../../bin/util', '../../bin/database',
          '../../bin/servers-init'.shutdown-mongo-client]
_ = require 'underscore'
_(global).extend require './test-merging-helper'

users-amount = 10

contacts-amount-config =
  mean: 30,
  std: 4,
  min: 1,
  max: 200

contacts-repeat-rate-config =
  mean: 0.2,
  std: 0.05,
  min: 0.01,
  max: 0.8

contacts-similar-rate-config =
  mean: 0.05,
  std: 0.01,
  min: 0.005,
  max: 0.1


can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe '大规模的用户注册时，能够正确的合并联系人', !->
  do
    (done) <-! before-each
    <-! initial-test-environment
    done!
  
  can '使用YoYo-Mock正确生成fake users\n', !(done) ->
    (users-data, fact) <-! creat-feak-users-data users-amount, (_.values contacts-amount-config), (_.values contacts-repeat-rate-config), (_.values contacts-similar-rate-config)
    (fact-table) <-! create-yoyo-users users-data, fact
    <-! check-yoyo-users-against-fact-table fact-table
    done!

  do
    (done) <-! after
    <-! shutdown-mongo-client
    done!
  

initial-test-environment = !(callback) ->
  (data) <- initial-environment
  callback!

creat-feak-users-data = !(user-amount, contacts-amount-config, contacts-repeat-rate-config, contacts-similar-rate-config, callback) ->
  (users-data, fact) <-! YoYo-Mock.Helpers.generate-fake-users user-amount, contacts-amount-config, contacts-repeat-rate-config, contacts-similar-rate-config
  # console.log "fact is: %j", fact
  # users[0].contacts = null
  # console.log "USER: \n%j", users[0]
  callback users-data, fact

create-yoyo-users = !(users-data, fact, callback) ->
  fact-table = {}
  combined-users-data = combine-users-data-and-fact users-data, fact
  (err) <-! async.for-each combined-users-data, !(combined-user-data, next) ->
    (user) <-! Users.create-user-with-contacts combined-user-data.user-data
    fact-table[user.uid] = combined-user-data.fact
    next!
  throw new Error err if err
  callback fact-table

combine-users-data-and-fact = (users-data, fact) ->
  [{user-data: user-data, fact: (_.values fact[index])[0]} for user-data, index in users-data]

check-yoyo-users-against-fact-table = !(fact-table, callback) ->
  (err) <-! async.for-each (_.keys fact-table), !(uid, next) ->
    (found-user) <-! should-find-one-user-with-cretiria {'uid': uid}
    found-user.contacts.length.should.eql fact-table[uid].diff-contacts-amount
    # found-user.contacts.should.have.length fact-table[uid].diff-contacts-amount
    next!
  throw new Error err if err
  callback!
