require! ['should', 'async', 
          '../../bin/servers-init'.init-mongo-client, 
          '../../bin/servers-init'.shutdown-mongo-client,
          '../../bin/database']
require! Sn: '../../bin/models/sn-update'

# 要升级anync为新版本，见pakage.json
# console.log async.eachLimit

# 1测试初始化
<-! Sn.initialize
# 2测试定时更新 todo 多个用户的测试，新增微博后再测，返回接口的测试
setInterval(Sn.get-sn-update-regular, 5000);



