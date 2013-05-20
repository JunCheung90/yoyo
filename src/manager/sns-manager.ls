require! Sns: '../models/sns', Users: '../models/users'
require! ['../util']
require! async
_ = require 'underscore'

Sns-manager =
  user-get-contact-sns-updates: !(uid, cid, since-id-configs, count, callback) ->
    (user) <-! Users.get-user-by-uid uid
    contact = _.find-where user.contacts, {cid: cid}
    callback {result-code: 3, error-message: "can not find contact with cid: #cid"}
    (err, contact-sns-updates, count) <-! Sns.get-user-sns-updates contact.act-by-user,since-id-configs, count
    callback {result-code: -1, error-message: err} if err
    callback {result-code: 0, contact-sns-updates: contact-sns-updates, count: count}
  
  user-get-sns-updates: !(uid, count, callback) ->
    sns-updates = []
    (user) <-! Users.get-user-by-uid uid
    (err) <-! async.for-each user.contacts, !(contact, next) ->
      (err, contact-sns-updates, count) <-! Sns.get-user-sns-updates contact.act-by-user,null, count
      sns-updates.push {cid: contact.cid, contact-sns-updates: contact-sns-updates, count: count} if not err
      next!
    throw new Error err if err
    callback {result-code: -1, error-message: err} if err
    callback {result-code: 0, sns-updates: sns-updates}

module.exports <<< Sns-manager