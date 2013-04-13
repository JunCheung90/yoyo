/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

require! [async, './Interesting-info-mining-strategy', '../../util']
_ = require 'underscore'
Checkers = require './interesting-info-checkers'

interesting-info-mining =
  mining-user-interesting-info: !(user, callback) ->
    <-! async-check-each-interesting-info-strategy user
    <-! util.update-multiple-docs 'users', [user]
    callback!

async-check-each-interesting-info-strategy = !(user, callback) ->
  (err) <-! async.for-each Interesting-info-mining-strategy.strategys, !(strategy, next) ->
    checker = util.to-camel-case strategy.checker
    <-! Checkers[checker] user, strategy.roles, strategy.time-quantum, strategy.fields
    next!
  throw new Error err if err
  callback!

# update-contacts-interesting-info = !(user, callback) ->
#   contacts = user.contacts
#   (err) <-! async.for-each contacts, !(contact, next) ->
#     if contact.merged-to?
#       next!
#     else
#       <-! check-contact-interestring-info user, contact
#       next!
#   throw new Error err if err  
#   <-!  util.update-multiple-docs 'users', [user]
#   callback!

# check-contact-interestring-info = !(user, contact, callback) ->
#   (err) <-! async.for-each Interesting-info-mining-strategy.strategys, !(strategy, next) ->
#     checker = util.to-camel-case strategy.checker
#     (check-result) <-! Checkers[checker] user, contact, strategy.roles, strategy.time-quantum, strategy.fields
#     contact.interesting-info = strategy.type if check-result
#     next!
#   throw new Error err if err
#   callback!
  

module.exports <<< interesting-info-mining