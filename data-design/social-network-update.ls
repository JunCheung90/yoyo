# TODO reject , 分开平台，last-modified, 一次返回多少条, 
social-network-update = # yoyo server端数据
  owner-id: 'uid-of-zhangsan'
  reject-to: ['uid-of-lisi', 'uid2'] # 授权可以访问sn更新的联系人列表. 
  type: '豆瓣'
  last-modified: 'UTC'
  updates:
    * update-time: 'UTC'
      update-contents: ['json_result1', 'json_result2']
    ...
      
require! fs

# 下面部分用来生成json数据
(err) <-! fs.writeFile 'sn_zhangsan.json', JSON.stringify(social-network-update, null, '\t')
throw new Error err if err
console.log "social-network-update data have been exported to sn_zhangsan.json"