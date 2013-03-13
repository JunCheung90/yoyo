require! ['should', 'async', 
          '../../bin/database', '../../bin/config/sn-config', '../test-helper', '../../bin/util']
require! Sn: '../../bin/models/sn-update'
_ = require 'underscore'


(db) <-! database.get-db

# 测试返回客户端接口
req-parms = 
  uid: 'uid-1'
  count: 2
(err, updates) <-! Sn.client-get-sn-update req-parms
console.log err if err
console.log (JSON.stringify updates, null, '\t')

