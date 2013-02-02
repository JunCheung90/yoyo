social-network-update = # yoyo server端数据
  owner-id: 'uid-of-zhangsan'
  authorize-to: ['uid-of-lisi', 'uid2'] # 授权可以访问sn更新的联系人列表
  updates:
    * type: '豆瓣'
      update-time: 'UTC'
      update-contents: ['json_result1', 'json_result2']
    ...
      
# 下面部分用来生成json数据
(err) <-! fs.writeFile 'sn_zhangsan.json', JSON.stringify(user, null, '\t')
throw new Error err if err
console.log "user data have been exported to sn_zhangsan.json"