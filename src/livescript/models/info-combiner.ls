require! '../util'
_ = require 'underscore'

combine-users-info = !(old-user, new-user) -> 
  # 这里的逻辑要更新，考虑各种复杂的信息合并情况。
  # TODO：应对数据中的错误，例如：电话号码错了一位等情况。
  # old-user <<< new-user
  combine-basic-info old-user, new-user
  combine-commnication-channels old-user, new-user
  combine-relations old-user, new-user #性能：可以提高。

combine-basic-info = !(old-user, new-user) ->
  old-user.last-modified-date = current = new Date!.get-time!
  combine-users-names old-user, new-user
  combine-avatars old-user, new-user
  combine-addresses old-user, new-user
  combine-tags old-user, new-user

combine-users-names = !(old-user, new-user) ->
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

combine-emails = !(old, _new) ->
  old.emails = _.union old.emails, _new.emails
  
combine-ims = !(old, _new) ->
  # is-active字段没有处理。
  combine-sns-ims old, _new, 'ims'

combine-sns-ims = !(old, _new, collection) ->
  # is-active字段没有处理。api-key字段没有处理。
  (old-items-map, new-item) <-! combine-on-collection old, _new, collection, 'account'
  old-items = old-items-map[new-item.account]
  old-items-types = [item.type for item in old-items]
  if new-item.type not in old-items-types
    old[collection].push new-item

combine-sns = !(old, _new) ->
  # is-active字段没有处理。
  combine-sns-ims old, _new, 'sns'

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

combine-users-mergences = !(old-user, new-user) ->
  combine-mergences old-user, new-user

combine-mergences = !(old, _new) ->
  if _new?.pending-merges?.length
    _new.merged-to = old.uid
    old.merged-from = _.union old.merged-from, _new.merged-from
    old.merged-from = _.union old.merged-from, _new.uid
    old-pending-merge-tos = [pm.pending-merge-to for pm in old.pending-merges when !pm.is-accepted and pm.pending-merge-to]
    old-pending-merge-froms = [pm.pending-merge-from for pm in old.pending-merges when !pm.is-accepted and pm.pending-merge-from]
    for pending-merge in _new?.pending-merges
      continue if is-accepted 
      if pending-merge.pending-merge-to and pending-merge.pending-merge-to not in old-pending-merge-tos
        old.pending-merges.push {'pending-merge-to': pending-merge.pending-merge-to, 'is-accepted': false}
      if pending-merge.pending-merge-from  and pending-merge.pending-merge-from not in old-pending-merge-froms
        old.pending-merges.push {'pending-merge-from': pending-merge.pending-merge-from, 'is-accepted': false}

add-users-pending-merges = !(old-user, new-user) ->
  add-pending-merges old-user, new-user

add-pending-merges = !(old, _new) ->
  old.pending-merges ||= []
  old.pending-merges.push {'pending-merge-from': _new.uid, 'is-accepted': false}
  _new.pending-merges ||= []
  _new.pending-merges.push {'pending-merge-to': old.uid, 'is-accepted': false}


combine-contacts-info = !(old-contact, new-contact) ->
  throw new Error "Merging contacts act by different user: #{old-contact.names[0]} act-by #{old-contact.act-by-user}, #{new-contact.names[0]} act-by #{new-contact.act-by-user}" if old-contact.act-by-user is not new-contact.act-by-user
  combine-contacts-names old-contact, new-contact
  combine-contacts-phones old-contact, new-contact
  combine-emails old-contact, new-contact
  combine-sns old-contact, new-contact

combine-contacts-names = !(old-contact, new-contact) ->
  _.union old-contact.names, new-contact.names

combine-contacts-phones = !(old-contact, new-contact) ->
  _.union old-contact.phones, new-contact.phones

combine-contacts-mergences = !(old-contact, new-contact) ->
  combine-mergences old-contact, new-contact

add-contacts-pending-merges = !(old-contact, new-contact) ->
  add-pending-merges old-contact, new-contact

module.exports = 
  combine-users-info: combine-users-info
  combine-users-mergences: combine-users-mergences
  add-users-pending-merges: add-users-pending-merges
  combine-contacts-info: combine-contacts-info
  combine-contacts-mergences: combine-contacts-mergences
  add-contacts-pending-merges: add-contacts-pending-merges