require! ['should', 'async', 
          '../../bin/database', '../../bin/config/sn-config', '../test-helper', '../../bin/util']
require! Sn: '../../bin/models/sn-update'
_ = require 'underscore'


db = null

<-! database.init-mongo-client
(db) <-! database.get-db

# 测试返回客户端接口
req-parms = 
  uid: 'uid-1'
  count: 2
(updates) <-! Sn.client-get-sn-update req-parms
# console.log updates
console.log (JSON.stringify updates, null, '\t')

