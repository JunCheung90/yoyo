# TODO: 完善yoyo-mock模块，模拟sn平台的接口，进行sn更新功能的大规模测试（性能）
require! ['should', 'async', 
          '../../bin/servers-init'.init-mongo-client, 
          '../../bin/servers-init'.shutdown-mongo-client,
          '../../bin/database', '../../bin/config/sn-config', '../test-helper', '../../bin/util']
require! Sn: '../../bin/models/sn-update'
_ = require 'underscore'

# 要升级anync为新版本，见pakage.json
# console.log async.eachLimit

create-user = !(json-file, uid, callback) ->
  userdata = util.load-json __dirname + "/../test-data/#{json-file}"
  userdata.uid = uid
  (err) <-! db.users.save userdata
  throw new Error err if err
  callback!

db = null

<-! init-mongo-client
<-! database.db.drop-collection 'users' 
<-! database.db.drop-collection 'sn-update' 
db := database.get-db!
<-! create-user "zhangsan.json", 'uid-1'
# <-! create-user "lisi.json", 'uid-2'
<-! create-user "zhaowu.json", 'uid-3'

# 1测试初始化
<-! Sn.initialize
# 2测试定时更新
setInterval(Sn.get-sn-update-regular, sn-config.update-interval)