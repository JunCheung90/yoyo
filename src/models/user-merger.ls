require! fqh: '../fast-query-helper'
require! ['./User', './Info-Combiner', '../util']

user-merger =
  create-user-then-merge-with-existed-user: !(user, callback) -> 
    # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
    (existed-user, is-direct-merge) <-! fqh.get-existed-repeat-user user 
    if existed-user
      throw new Error "Can't merge a user: #{user.name} to an existed-user: #{existed-user.name} already being merged to others #{existed-user.merged-to}" if existed-user.merged-to
      throw new Error "Can't merge a already mereged user: #{user.name}, merged-to: #{user.merged-to} to an existed-user: #{existed-user.name}" if user.merged-to
      if is-direct-merge
        user-merger.direct-merge-users existed-user, user
        callback existed-user, null # 彻底合并了，只需要更新一个user了。
      else
        user-merger.pendings-merge-users  existed-user, user
        callback existed-user, user # pending合并，需要更新existed user，并新建user
    else
      callback null, user #只需新建user

  get-repeat-users: !(user, callback) ->
    (users) <-! fqh.get-repeat-users user
    callback users

  direct-merge-users: !(old-user, new-user) ->
    # throw new Error "不能够自动合并两个已经存在的用户！" if new-user.uid
    Info-Combiner.combine-users-info old-user, new-user
    if new-user.uid # new-user为已有用户，为手动合并。
      Info-Combiner.combine-users-mergences  old-user, new-user
      # 希望新建的用户。对于希望新建的用户如果要merge到其它用户，不用新建，直接copy信息就好了。
    else # 希望新建的用户。对于希望新建的用户如果要merge到其它用户，不用新建，直接copy信息就好了。
      # User.add-user-mergence-info old-user, new-user
      old-user.is-updated = true # 自动合并后，需要进一步手动评估mergences。
    # util.event.emit 'user-info-updated', old-user, new Date!
    # User.user-info-updated-handler old-user if old-user?.pending-merges?.length # 是否应该回调?

  pendings-merge-users: !(old-user, new-user) ->
    Info-Combiner.add-users-pending-merges old-user, new-user

module.exports = user-merger 