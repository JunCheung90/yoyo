require! fqh: '../fast-query-helper'
require! '../util'
_ = require 'underscore'

user-merger =
  merge-same-users: !(db, user, callback) -> 
    # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
    (existed-user, is-direct-merge) <-! fqh.get-existed-repeat-users db, user 
    if existed-user
      throw new Error "Can't merge a user: #{user.name} to an existed-user: #{existed-user.name} already being merged to others #{existed-user.merged-to}" if existed-user.merged-to
      throw new Error "Can't merge a already mereged user: #{user.name}, merged-to: #{user.merged-to} to an existed-user: #{existed-user.name}" if user.merged-to
      if is-direct-merge
        combine-users-info existed-user, user
        combine-mergences  existed-user, user if user.uid # user为已有用户，否则是希望新建的用户。对于希望新建的用户如果要merge到其它用户，不用新建，直接copy信息就好了。
        re-evaluate-user-pending-mergences db, existed-user if existed-user?.pending-merges?.length # 是否应该回调？
        callback existed-user, null # 彻底合并了，只需要更新一个user了。
      else
        existed-user.pending-merges ||= []
        existed-user.pending-merges.push {'pending-merge-from': user.uid, 'is-accepted': false}
        user.pending-merges ||= []
        user.pending-merges.push {'pending-merge-to': existed-user.uid, 'is-accepted': false}
        callback existed-user, user
    else
      callback null, user

combine-users-info = !(old-user, new-user) -> 
  # 这里的逻辑要更新，考虑各种复杂的信息合并情况。
  # TODO：应对数据中的错误，例如：电话号码错了一位等情况。
  # old-user <<< new-user
  combine-basic-info old-user, new-user
  combine-commnication-channels old-user, new-user
  combine-relations old-user, new-user #性能：可以提高。

combine-basic-info = !(old-user, new-user) ->
  old-user.last-modified-date = current = new Date!.get-time!
  combine-names old-user, new-user
  combine-avatars old-user, new-user
  combine-addresses old-user, new-user
  combine-tags old-user, new-user

combine-names = !(old-user, new-user) ->
  if !old-user.name
    old-user.name = new-user.name
  else
    old-user.nicknames = _.union old-user.nicknames, new-user.name
  old-user.nicknames = _.union old-user.nicknames, new-user.nicknames

combine-avatars = !(old-user, new-user) ->
  old-user.avatars = _.union old-user.avatars, new-user.avatars

combine-addresses = !(old-user, new-user) ->
  old-user.addresses = _.union old-user.addresses, new-user.addresses

combine-tags = !(old-user, new-user) ->
  old-user.tags = _.union old-user.tags, new-user.tags

combine-commnication-channels = !(old-user, new-user) ->
  combine-phones old-user, new-user
  combine-emails old-user, new-user
  combine-ims old-user, new-user
  combine-sns old-user, new-user

combine-phones = !(old-user, new-user) ->
  (old-user-phones-map, new-phone) <-! combine-on-collection old-user, new-user, 'phones', 'phone-number'
  old-phone = old-user-phones-map[new-phone.phone-number][0]
  throw new Error "Merging users: #{old-user.name} and #{new-user.name} are different on 'is-active' on the phone #{new-phone.phone-number}" if new-phone.is-active is not old-phone.is-active
  combine-phone-in-using-time old-phone, new-phone

combine-on-collection = !(old-user, new-user, collection, distingusih-attr, conflict-handler) ->
  old-elements-map = util.create-map-on-attribute old-user[collection], distingusih-attr
  for new-element in new-user[collection]
    if !old-elements-map[new-element[distingusih-attr]]
      old-user[collection] ||= []
      old-user[collection].push new-element
    else
      conflict-handler old-elements-map, new-element

# combine-phones-conflict-handler = !(old-user, new-user, old-user-phones-map, new-phone) ->
#   old-phone = old-user-phones-map[phone.phone-number][0]
#   throw new Error "Merging users: #{old-user.name} and #{new-user.name} are different on 'is-active' on the phone #{new-phone.phone-number}" if new-phone.is-active is not old-phone.is-active
#   combine-phone-in-using-time old-phone, new-phone

combine-phone-in-using-time = !(old-phone, new-phone) ->
  old-phone.start-using-time ||= new-phone.start-using-time
  old-phone.end-using-time ||= new-phone.end-using-time
  old-phone.start-using-time = new-phone.start-using-time if new-phone.start-using-time and util.is-early new-phone.start-using-time, old-phone.start-using-time
  old-phone.end-using-time = new-phone.end-using-time if new-phone.end-using-time and util.is-late new-phone.end-using-time, old-phone.end-using-time

combine-emails = !(old-user, new-user) ->
  old-user.emails = _.union old-user.emails, new-user.emails
  
combine-ims = !(old-user, new-user) ->
  # is-active字段没有处理。
  combine-sns-ims old-user, new-user, 'ims'

combine-sns-ims = !(old-user, new-user, collection) ->
  # is-active字段没有处理。
  (old-user-items-map, new-item) <-! combine-on-collection old-user, new-user, collection, 'account'
  old-items = old-user-items-map[new-item.account]
  old-items-types = [item.type for item in old-items]
  if new-item.type not in old-items-types
    old-user[collection].push new-item

combine-sns = !(old-user, new-user) ->
  # is-active字段没有处理。
  combine-sns-ims old-user, new-user, 'sns'

combine-relations = !(old-user, new-user) ->
  combine-contacts old-user, new-user
  # console.log "\n\n*************** old-user: #{old-user.name}, old-as: #{old-user.as-contact-of}, new-user: #{new-user.name}, new-as: #{new-user.as-contact-of}***************\n\n"
  if new-user?.as-contact-of?.length
    old-user.as-contact-of = _.union old-user.as-contact-of, new-user.as-contact-of
  combine-strangers old-user, new-user

combine-contacts = !(old-user, new-user) ->
  (old-user-contacts-map, new-contact) <-! combine-on-collection old-user, new-user, 'contacts', 'cid'

combine-strangers = !(old-user, new-user) ->
  old-user.contacted-strangers = _.union old-user.contacted-strangers, new-user.contacted-strangers
  old-user.contacted-by-strangers = _.union old-user.contacted-by-strangers, new-user.contacted-by-strangers

combine-mergences = !(old-user, new-user) ->
  if new-user?.pending-merges?.length
    new-user.merged-to = old-user.uid
    old-user.merged-from = _.union old-user.merged-from, new-user.merged-from
    old-user.merged-from = _.union old-user.merged-from, new-user.uid
    old-pending-merge-tos = [pm.pending-merge-to for pm in old-user.pending-merges when !pm.is-accepted and pm.pending-merge-to]
    old-pending-merge-froms = [pm.pending-merge-from for pm in old-user.pending-merges when !pm.is-accepted and pm.pending-merge-from]
    for pending-merge in new-user?.pending-merges
      continue if is-accepted 
      if pending-merge.pending-merge-to and pending-merge.pending-merge-to not in old-pending-merge-tos
        old-user.pending-merges.push {'pending-merge-to': pending-merge.pending-merge-to, 'is-accepted': false}
      if pending-merge.pending-merge-from  and pending-merge.pending-merge-from not in old-pending-merge-froms
        old-user.pending-merges.push {'pending-merge-from': pending-merge.pending-merge-from, 'is-accepted': false}


re-evaluate-user-pending-mergences = !(db, existed-user) ->
  #TODO:
  console.log 'NOT IMPLEMENTED YET'

module.exports = user-merger  