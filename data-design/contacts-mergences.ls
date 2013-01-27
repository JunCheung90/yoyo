contacts-mergences = # 记录某个用户的联系人合并历史
  owner: "uid" # 该用户的uid
  mergences:
    * from: 'cid-1'
      to: 'cid-2'
      is-direct-mergence: false # true为直接合并，不需要用户确认。false为需要用户确认，用户确认后，依然为false。
      start-time: 'timestamp of this mergence start' 
      # ------------- 以下字段，只有推荐合并才有 ----------------------- #
      end-time: 'timestamp of this mergence end' # 推荐合并用户接受或者拒绝的时间。直接合并没有这个字段。
      is-user-accepted: false # 用户最后是否接受了合并。
    ...

  
require! fs

# 下面部分用来生成json数据
(err) <-! fs.writeFile 'contacts-mergences.json', JSON.stringify(user, null, '\t')
throw new Error err if err
console.log "user data have been exported to contacts-mergences.json"