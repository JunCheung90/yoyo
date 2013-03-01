# 1.初始化：遍历user表，拿到有sn信息的用户
# 2.每个有sn的用户新建sn-update表，客户端的key发送变化后，先更新user，再更新sn?
# 3.定时执行以下功能：
# 向sina拿数据，比较since_id参数，若有更新过的微博，抓下来，按格式插入updates，最后更新last-modified
# 同理，向客户端返回时候，先比较last-modified的时间，若有更新，即返回update-time在两个last-modified之间的update-content(返
# 回所有？还是只返回最新的N条？)
# 返回客户端的接口格式？（？userID & last-modified）
social-network-update = # yoyo server端数据
  owner-id: 'uid-of-zhangsan'
  type: '豆瓣'
  account-name: '张三豆'
  account-id: '1213213' # acount-name和account-id两者必须有一个
  api-key: 'xxxx' # 社交平台端授权后得到的key，用以从SN获取信息，由手机客户端上传
  reject-to: ['uid-of-lisi', 'uid2'] # 授权可以访问sn更新的联系人列表. 
  last-modified: 'UTC'
  since-id: 32323 # 最后一次更新的微博id
  updates:
    * update-time: 'UTC'
    	is-requested: false	#客户端是否已经请求过
      update-contents: ['json_result1', 'json_result2']
    ...
      
require! fs

# 下面部分用来生成json数据
(err) <-! fs.writeFile 'sn_zhangsan.json', JSON.stringify(social-network-update, null, '\t')
throw new Error err if err
console.log "social-network-update data have been exported to sn_zhangsan.json"