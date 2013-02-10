require! fqh: '../fast-query-helper'
require! ['./User', './Info-Combiner']

user-merger =
  create-user-then-merge-with-existed-user: !(db, user, callback) -> 
    # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
    (existed-user, is-direct-merge) <-! fqh.get-existed-repeat-user db, user 
    if existed-user
      throw new Error "Can't merge a user: #{user.name} to an existed-user: #{existed-user.name} already being merged to others #{existed-user.merged-to}" if existed-user.merged-to
      throw new Error "Can't merge a already mereged user: #{user.name}, merged-to: #{user.merged-to} to an existed-user: #{existed-user.name}" if user.merged-to
      if is-direct-merge
        <-! direct-merge-users existed-user, user
        callback existed-user, null # 彻底合并了，只需要更新一个user了。
      else
        <-! pendings-merge-users  existed-user, user
        callback existed-user, user # pending合并，需要更新existed user，并新建user
    else
      callback null, user #只需新建user

direct-merge-users = (old-user, new-user, callback) ->
  Info-Combiner.combine-users-info old-user, new-user
  Info-Combiner.combine-users-mergences  old-user, new-user if new-user.uid # new-user为已有用户，否则是希望新建的用户。对于希望新建的用户如果要merge到其它用户，不用新建，直接copy信息就好了。
  User.add-user-mergence-info old-user, new-user
  re-evaluate-user-pending-mergences db, old-user if old-user?.pending-merges?.length # 是否应该回调?
  callback!

pendings-merge-users = (old-user, new-user, callback) ->
  Info-Combiner.add-users-pending-merges old-user, new-user
  callback!

re-evaluate-user-pending-mergences = !(db, existed-user) ->
  #TODO:
  console.log 'NOT IMPLEMENTED YET'

module.exports = user-merger 