/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */

require! [async, '../../util']
require! II-strategy: './interesting-info-mining-strategy', Checkers: './interesting-info-checkers'
_ = require 'underscore'

interesting-info-mining =
  mining-user-interesting-info: !(user, callback) ->
    <-! async-check-each-interesting-info-strategy user
    <-! util.update-multiple-docs 'users', [user]
    callback!

async-check-each-interesting-info-strategy = !(user, callback) ->
  (err) <-! async.for-each II-strategy.strategys, !(strategy, next) ->
    checker = util.to-camel-case strategy.checker
    <-! Checkers[checker] user, strategy
    next!
  throw new Error err if err
  callback!

module.exports <<< interesting-info-mining