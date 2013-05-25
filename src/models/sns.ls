require! ['../db/database','yoyo-sn', '../config/sn-config', '../util', async]

Sns = 
  get-user-sns-updates: !(uid, since-id-config, count, callback) ->
    max-update-amount = count || sn-config.max-update-amount
    since-id-configs = since-id-configs || sn-config.since-id-default-configs;  # 第一次请求返回全部
    sns-updates = []
    count = 0
    (err) <-! async.each since-id-configs, !(since-id-config, next) ->
      (err, sns-update-result) <-! client-get-one-type-sns-update uid, since-id-config, max-update-amount
      callback err if err
      if sns-update-result != null
        updates = sns-update-result.updates.reverse!
        sn-update-result.updates = updates
        sns-updates.push sn-update-result
        count += updates.length
      next!
    callback err if err
    callback null, sns-updates, count

client-get-one-type-sns-update = !(uid, config, max-update-amount, callback) ->
  (db) <-! database.get-db
  query = 
    owner-id: uid
    since-id: {$gt: config.since-id}
    type: config.type
  projection = 
    _id: 0
    type: 1
    since-id: 1
    updates: {$slice: -max-update-amount}  # 只返回最新的条目
  (err, sn-update-result) <-! db.sn-update.find-one(query, projection)
  callback err if err
  callback null, sn-update-result

module.exports <<< Sns