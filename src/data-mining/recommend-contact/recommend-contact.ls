require! [async, '../../util']
require! RC-strategy: './recommend-contact-strategy'
require! Checkers: './recommend-contact-checkers'
_ = require 'underscore'

recommend-contact =
  update-user-recommend-info: !(user,callback) ->
    <-! async-check-each-recommend-info-strategy user
    <-! util.update-multiple-docs 'users', [user]
    callback!

async-check-each-recommend-info-strategy = !(user,callback) ->
  (err) <-! async.for-each RC-strategy.strategys, !(strategy, next) ->
    checker = util.to-camel-case strategy.checker
    <-! Checkers[checker] user, strategy
    next!
  throw new Error err if err
  callback!

module.exports <<< recommend-contact
