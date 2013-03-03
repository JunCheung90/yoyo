require! ['../database','yoyo-sn', '../config/sn-config', async]
require! ['../servers-init'.init-mongo-client, '../servers-init'.shutdown-mongo-client]

Sn =
  initialize: !(callback) ->  #第一次启动时或有新的有sn用户注册时创建sn-update文档
    <-! init-mongo-client
    (users) <-! get-user-has-sn
    (err) <-! async.each-limit users, sn-config.batch-limit, !(user-data, next) ->
      for sn, i in user-data.sns
        sn-update-doc = create-sn-base-info user-data, sn 
        # 第一次更新
        create-sn-update-for-one-user sn-update-doc
      next!  
    throw new Error err if err
    callback!

  get-sn-update-regular: !-> #定时更新已经存在的sn-update文档
    db = database.get-db!
    (err, sn-update-docs) <-! db.sn-update.find({}, {updates: 0}).to-array # 不用updates的主体部分
    throw new Error err if err
    (err) <-! async.each-limit sn-update-docs, sn-config.batch-limit, !(sn-update-doc, next) ->
      get-sn-update-for-one-user sn-update-doc
      next!
    throw new Error err if err  

  # 返回客户端接口，请求参数（？uid & since-id-configs & count），数据模型见client-sn-update-sample.ls
  client-get-sn-update: !(req-parms, callback) ->
    db = database.get-db!
    max-update-amount = req-parms.count || config.max-update-amount
    content = []
    count = 0
    for since-id-config, i in since-id-configs
      (sn-update-result) <-! client-get-one-type-sn-update since-id-config
      sn-update-result.updates = sn-update-result.updates.slice 0, max-update-amount
      content.push! sn-update-result
      count ++ sn-update-result.updates.length
    client-sn-update = {}
    client-sn-update.content = content
    client-sn-update.count = count
    callback client-sn-update    

client-get-one-type-sn-update = !(config, callback) ->
  query = 
    ower-id: req-parms.uid
    since-id: {$gt: since-id-config.since-id}
    type: since-id-config.type
  projection = 
    type: 1
    since-id: 1
    updates: {$elemMatch: {id: {$gt: since-id-config.since-id}}}  
  (err, sn-update-result) <-! db.sn-update.find-one query, projection
  throw new Error err if err
  callback sn-update-result

create-sn-update-for-one-user = !(sn-update-doc) ->
  sn-link = initialize-link sn-update-doc
  config = {} <<< {count: sn-config.update-amount}
  (update) <-! get-sn-update-by-config sn-link, config    
  db = database.get-db!;
  sn-update-doc.updates = update
  sn-update-doc.since-id = update[0].id
  (err) <-! db.sn-update.save sn-update-doc
  throw new Error err if err
  console.log "update created.\n"

get-sn-update-for-one-user = !(sn-update-doc) ->
  sn-link = initialize-link sn-update-doc 
  #TODO yoyo-sn模块应封装其他sn平台的参数请求/返回数据接口与现用的一致
  config = {} <<< {count: sn-config.update-amount, since-id: sn-update-doc.since-id}
  (update) <-! get-sn-update-by-config sn-link, config
  db = database.get-db!;
  query = {_id: sn-update-doc._id}
  projection =
    $set: { 
      'sinceId': update[0].id
    }
    $pushAll: {updates: update} 
  (err) <-! db.sn-update.update query, projection
  throw new Error err if err
  console.log "update saved.\n"

get-sn-update-by-config = !(sn-link, config, callback) ->
  (err, update) <-! sn-link.user_timeline config
  throw new Error err if err
  # TODO 转换数据格式，目前未清除冗余信息(deep-replace 本地json, 目标json)
  transform-update = update.statuses
  callback transform-update    

get-user-has-sn = !(callback) ->
  db = database.get-db!;
  query = {sns: {$ne: []}}
  projection =
    uid: 1
    sns: 1
  (err, found-users) <-! db.users.find(query, projection).to-array
  throw new Error err if err
  callback found-users    

create-sn-base-info = (user-data, sn) ->
  base-info = {} <<< sn
  base-info.ower-id = user-data.uid  
  base-info.since-id = null  
  base-info.updates = []
  base-info  
    
initialize-link = (sn-update-doc) ->
  user-key = {}
  user-key.access_token = sn-update-doc.api-key 
  sn-type = sn-update-doc.type
  Sn = yoyo-sn[sn-type]
  sn-link = new Sn(user-key)

user-key = 
  access_token: '2.00swKOcCCybyeCa4691e40davR53uC'
  uid: '2397145114'
  screen_name: '北上的风'  

module.exports <<< Sn