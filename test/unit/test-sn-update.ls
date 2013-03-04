require! ['should', 'async', 
          '../../bin/servers-init'.init-mongo-client, 
          '../../bin/servers-init'.shutdown-mongo-client,
          '../../bin/database', '../../bin/config/sn-config', '../test-helper', '../../bin/util']
require! Sn: '../../bin/models/sn-update'
_ = require 'underscore'

# 要升级anync为新版本，见pakage.json
# console.log async.eachLimit

create-user = !(json-file, uid, callback) ->
  userdata = util.load-json "../test-data/#{json-file}"
  userdata.uid = uid
  (err) <-! db.users.save userdata
  throw new Error err if err
  callback!

db = null

<-! init-mongo-client
# <-! database.db.drop-collection 'users' 
<-! database.db.drop-collection 'sn-update' 
db := database.get-db!
# <-! create-user "zhangsan.json", 1
# <-! create-user "lisi.json", 2
# <-! create-user "zhaowu.json", 3

# 1测试初始化
<-! Sn.initialize
# 2测试定时更新
# setInterval(Sn.get-sn-update-regular, sn-config.update-interval);
# 3测试返回客户端接口
req-parms = 
  uid: 1
  count: 2
(updates) <-! Sn.client-get-sn-update req-parms
console.log updates
