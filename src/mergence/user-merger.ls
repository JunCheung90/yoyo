require! qh: '../db/query-helper'
require! Info-Combiner: '../models/helpers/info-combiner'
require! '../util'
require! Contact-Merger: './contact-merger'
require! common: './user-contact-common'

user-merger =
  create-user-then-merge-with-existed-user: !(user, callback) ~> 
    # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
    (existed-user, is-direct-merge) <-! qh.get-existed-repeat-user user 
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
    (users) <-! qh.get-repeat-users user
    callback users

  direct-merge-users: !(distination, source) ->
    # throw new Error "不能够自动合并两个已经存在的用户！" if source.uid
    Info-Combiner.combine-users-info distination, source
    if source.uid # new-user为已有用户，为手动合并。
      Info-Combiner.combine-users-merge  distination, source
      common.update-pending-merges distination, source
      distination.is-updated = false # 手动合并之后，标识为false。
      update-related-contacts distination.uid, source.uid, source.as-contact-of
      # 希望新建的用户。对于希望新建的用户如果要merge到其它用户，不用新建，直接copy信息就好了。
    else # 希望新建的用户。对于希望新建的用户如果要merge到其它用户，不用新建，直接copy信息就好了。
      distination.is-updated = true # 新建contact-user时，将contact-user自动合并到已有用户后，需要进一步手动评估已有用户的mergences。

  pendings-merge-users: !(distination, source) ->
    Info-Combiner.add-users-pending-merges distination, source

update-related-contacts = !(distination-uid, source-uid, owners-uids) ->
  if owners-uids?.length
    (owners) <-! qh.get-users-by-uids owners-uids
    for owner in owners
      distination-contacts = filter (-> it.act-by-user is distination-uid and not it.merged-to), owner.contacts
      source-contacts = filter (-> it.act-by-user is source-uid and not it.merged-to), owner.contacts
      if distination-contacts.length
        Contact-Merger.direct-merge-contacts source-contacts[0], distination-contacts[0]
      else 
        source-contacts[0].act-by-user = distination-uid
    util.update-multiple-docs 'users', owners, (->) # 这里为异步操作

module.exports <<< user-merger 
