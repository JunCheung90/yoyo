require! ['../database','yoyo-sn', '../config/sn-config', '../util', async]

Sn =
  # 第一次启动时为已存在sn的用户创建sn-update文档
  initialize: !(callback) -> 
    self = this
    (users) <-! get-user-has-sn
    (err) <-! async.each-limit users, sn-config.batch-limit, !(user-data, next) ->
      self.register-new-user user-data
      next!  
    throw new Error err if err
    callback!

  # 有新的有sn用户注册时创建sn-update文档
  register-new-user: !(user-data) ->
    for sn, i in user-data.sns
      sn-update-doc = create-sn-base-info user-data, sn 
      # 第一次更新
      create-sn-update-for-one-user sn-update-doc

  # 定时更新已经存在的sn-update文档
  get-sn-update-regular: !->
    (db) <-! database.get-db
    (err, sn-update-docs) <-! db.sn-update.find({}, {updates: 0}).to-array # 不用updates的主体部分
    throw new Error err if err
    (err) <-! async.each-limit sn-update-docs, sn-config.batch-limit, !(sn-update-doc, next) ->
      get-sn-update-for-one-user sn-update-doc
      next!
    throw new Error err if err  

  # 返回客户端接口，请求参数（？uid & since-id-configs & count），数据模型见client-sn-update-sample.ls
  client-get-sn-update: !(req-parms, callback) ->
    # TODO: 应该加入参数合法检测
    uid = req-parms.uid
    max-update-amount = req-parms.count || sn-config.max-update-amount
    since-id-configs = req-parms.since-id-configs || sn-config.since-id-default-configs;  # 第一次请求返回全部
    content = []
    count = 0
    (err) <-! async.each since-id-configs, !(since-id-config, next) ->
      (err, sn-update-result) <-! client-get-one-type-sn-update uid, since-id-config, max-update-amount
      callback err if err
      if sn-update-result != null
        updates = sn-update-result.updates.reverse!
        sn-update-result.updates = updates
        content.push sn-update-result
        count += updates.length
      next!
    callback err if err
    client-sn-update = {} <<< {content, count}
    callback null, client-sn-update   

client-get-one-type-sn-update = !(uid, config, max-update-amount, callback) ->
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

create-sn-update-for-one-user = !(sn-update-doc) ->
  sn-link = initialize-link sn-update-doc
  config = {} <<< {count: sn-config.update-amount}
  (update) <-! get-sn-update-by-config sn-link, config    
  (db) <-! database.get-db
  sn-update-doc.since-id = update[0].id
  # 最新的更新在数组末尾
  sn-update-doc.updates = update.reverse!
  (err) <-! db.sn-update.save sn-update-doc
  throw new Error err if err
  console.log "update created.\n"

get-sn-update-for-one-user = !(sn-update-doc) ->
  sn-link = initialize-link sn-update-doc 
  #TODO yoyo-sn模块应封装其他sn平台的参数请求/返回数据接口与现用的（新浪微博）一致
  config = {} <<< {count: sn-config.update-amount, since_id: sn-update-doc.since-id}
  (update) <-! get-sn-update-by-config sn-link, config
  if update.length
    (db) <-! database.get-db;
    query = {_id: sn-update-doc._id}
    projection =
      $set: { 
        'sinceId': update[0].id
      }
      # 最新的更新在数组末尾，由于mongodb暂不支持从数组最前插入
      $pushAll: {updates: update.reverse!} 
    (err) <-! db.sn-update.update query, projection
    throw new Error err if err
    console.log "update saved.\n"

get-sn-update-by-config = !(sn-link, config, callback) ->
  (err, update-result) <-! sn-link.user_timeline config
  console.log err if err
  # 转换数据格式，清除冗余信息(deep-replace 本地数据模式json, 目标json)
  update-sample = util.load-json __dirname + "../../../data-design/sn-update-content-sample.json"
  (err, transform-updates) <-! async.map update-result.statuses, !(update, next) ->
    next null, util.clean-json update, update-sample
  throw new Error err if err
  # 拿回的最新更新在数组最前
  callback transform-updates   

get-user-has-sn = !(callback) ->
  (db) <-! database.get-db
  query = {sns: {$ne: []}}
  projection =
    uid: 1
    sns: 1
  (err, found-users) <-! db.users.find(query, projection).to-array
  throw new Error err if err
  callback found-users    

create-sn-base-info = (user-data, sn) ->
  base-info = {} <<< sn
  base-info.owner-id = user-data.uid  
  base-info.since-id = null  
  base-info.updates = []
  base-info  
    
initialize-link = (sn-update-doc) ->
  user-key = {}
  user-key.access_token = sn-update-doc.api-key 
  sn-type = sn-update-doc.type
  Sn = yoyo-sn[sn-type]
  sn-link = new Sn(user-key)

module.exports <<< Sn