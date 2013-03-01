require! ['../database','yoyo-sn', '../config/sn-config']
require! ['../servers-init'.init-mongo-client, '../servers-init'.shutdown-mongo-client]

Sn =
  initialize: !() ->  #第一次启动时或有新的有sn用户注册时创建sn-update文档
    <-! init-mongo-client
    (users) <-! get-user-has-sn
    (err) <-! async.each-limit users, sn-config.batch-limit, !(user-data, next) ->
      for sn, i in user-data.sns
        user-sn-info = create-sn-base-info user-data, sn 
        # 第一次更新
        create-sn-update-for-one-user user-sn-info
      next!  
    throw new Error err if err

  get-sn-update-regular: !() -> #定时更新已经存在的sn-update文档
    db = database.get-db!
    (err, sn-update-docs) <-! db.sn-update.find(
        {},
        {
          updates: 0 # 不用updates的主体部分
        }
      ).to-array
    throw new Error err if err
    (err) <-! async.each sn-update-docs, sn-config.batch-limit, !(sn-update-doc, next) ->

      next!
    throw new Error err if err  

create-sn-update-for-one-user = !(user-sn-info) ->
  sn-link = @initialize-link user-sn-info
  config = {} <<< {count: sn-config.update-amount}
  (update) <-! get-sn-update-by-config config    
  db = database.get-db!;
  # TODO
  sn-update-doc = {} <<< update + user-sn-info
  (err) <-! db.sn-update.save sn-update-doc
  throw new Error err if err
  console.log "update created.\n"

get-sn-update-for-one-user = !(sn-update-doc) ->
  sn-link = @initialize-link sn-update-doc 
  config = {} <<< {count: sn-config.update-amount, since-id: sn-update-doc.since-id}
  (update) <-! get-sn-update-by-config config
  db = database.get-db!;
  (err) <-! db.sn-update.update (
      {_id: sn-update-doc._id},
      {
        $push: {updates: update}  # TODO update是子数组插入会有问题！
      }
    )
  throw new Error err if err
  console.log "update saved.\n"

get-sn-update-by-config = !(config, callback) ->
  (err, update) <-! sn-link.user_timeline config
  throw new Error err if err
  # 转换数据格式 TODO
  transform-update = [] <<< 
  callback update    

get-user-has-sn = !(callback) ->
  db = database.get-db!;
  (err, found-users) <-! db.users.find (
      {sns: {$ne: []}},
      {
        uid: 1
        sns: 1
      }
    ).to-array
  throw new Error err if err
  callback found-users    

create-sn-base-info = (user-data, sn) ->
  base-info = {} <<< sn
  base-info.ower-id = user-data.uid  
  base-info.last-modified = null  
  base-info.since-id = null  
  base-info.updates = []
  base-info  
    
initialize-link = (user-sn-info) ->
  user-key = {}
  user-key.access_token = user-sn-info.api-key 
  sn-type = user-sn-info.type
  Sn = yoyo-sn[sn-type]
  sn-link = new Sn(user-key)

user-key = 
  access_token: '2.00swKOcCCybyeCa4691e40davR53uC'
  uid: '2397145114'
  screen_name: '北上的风'  

Sn.get-sn-update user-key, 'Weibo'

module.exports <<< Sn