require! '../../util'
_ = require 'underscore'
$C = util.to-camel-case 

info-combiner =
  combine-users-info: !(old-user, new-user) -> 
    # 这里的逻辑要更新，考虑各种复杂的信息合并情况。
    # TODO：应对数据中的错误，例如：电话号码错了一位等情况。
    # old-user <<< new-user
    combine-user-basic-info old-user, new-user
    combine-commnication-channels old-user, new-user
    combine-relations old-user, new-user #性能：可以提高。

  combine-users-merge: !(old-user, new-user) ->
    combine-mergences old-user, new-user, 'uid'

  add-users-pending-merges: !(old-user, new-user) -> 
    add-pending-merges old-user, new-user, 'uid'

  combine-contacts-info: !(old-contact, new-contact) ->
    # throw new Error "Merging contacts act by different user: #{old-contact.names[0]} act-by #{old-contact.act-by-user}, #{new-contact.names[0]} act-by #{new-contact.act-by-user}" if old-contact.act-by-user is not new-contact.act-by-user
    combine-contacts-names old-contact, new-contact
    combine-contacts-phones old-contact, new-contact
    combine-emails old-contact, new-contact
    combine-sns old-contact, new-contact
    combine-ims old-contact, new-contact
    combine-local-photo old-contact, new-contact

  combine-contacts-merge: !(old-contact, new-contact) ->
    combine-mergences old-contact, new-contact, 'cid'

  add-contacts-pending-merges: !(old-contact, new-contact) ->
    add-pending-merges old-contact, new-contact, 'cid'

combine-user-basic-info = !(old-user, new-user) ->
  old-user.last-modified-date = current = new Date!.get-time!
  combine-users-names old-user, new-user
  combine-avatars old-user, new-user
  combine-addresses old-user, new-user
  combine-tags old-user, new-user

combine-users-names = !(old-user, new-user) ->
  if !old-user.name
    old-user.name = new-user.name
  else
    old-user.nicknames = util.union old-user.nicknames, new-user.name if new-user.name
  old-user.nicknames = util.union old-user.nicknames, new-user.nicknames

combine-avatars = !(old-user, new-user) ->
  old-user.avatars = util.union old-user.avatars, new-user.avatars

combine-addresses = !(old-user, new-user) ->
  old-user.addresses = util.union old-user.addresses, new-user.addresses

combine-tags = !(old-user, new-user) ->
  old-user.tags = util.union old-user.tags, new-user.tags

combine-commnication-channels = !(old-user, new-user) ->
  combine-user-phones old-user, new-user
  combine-emails old-user, new-user
  combine-ims old-user, new-user
  combine-sns old-user, new-user

combine-user-phones = !(old-user, new-user) ->
  if new-user?.phones?.length
    (old-user-phones-map, new-primary-phone) <-! combine-on-collection old-user, new-user, 'phones', ($C 'phone-number')
    old-primary-phone = old-user-phones-map[new-primary-phone.phone-number][0]
    check-active-phone old-primary-phone, new-primary-phone

check-active-phone = !(old-phone, new-phone) ->
  # throw new Error "Merging users: #{old-user.name} and #{new-user.name} are different on 'is-active' on the phone #{new-phone.phone-number}" if new-phone.is-active is not old-phone.is-active
  combine-phone-in-using-time old-phone, new-phone

combine-on-collection = !(old-user, new-user, collection, distingusih-attr, conflict-handler) ->
  old-elements-map = util.create-map-on-attribute old-user[collection], distingusih-attr
  for new-element in new-user[collection]
    if !old-elements-map[new-element[distingusih-attr]]
      old-user[collection] ||= []
      old-user[collection].push new-element
    else
      conflict-handler old-elements-map, new-element

combine-phone-in-using-time = !(old-phone, new-phone) ->
  old-phone.start-using-time ||= new-phone.start-using-time
  old-phone.end-using-time ||= new-phone.end-using-time
  old-phone.start-using-time = new-phone.start-using-time if new-phone.start-using-time and util.is-early new-phone.start-using-time, old-phone.start-using-time
  old-phone.end-using-time = new-phone.end-using-time if new-phone.end-using-time and util.is-late new-phone.end-using-time, old-phone.end-using-time

combine-emails = !(old, _new) ->
  old.emails = util.union old.emails, _new.emails
  
combine-ims = !(old, _new) ->
  # is-active字段没有处理。
  combine-sns-ims old, _new, 'ims'

combine-sns-ims = !(old, _new, collection) ->
  # is-active字段没有处理。api-key字段没有处理。
  if _new[collection] and _new[collection]?.length
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
    old-user.as-contact-of = util.union old-user.as-contact-of, new-user.as-contact-of
  combine-strangers old-user, new-user

combine-contacts = !(old-user, new-user) ->
  if new-user?.contacts?.length
    (old-user-contacts-map, new-contact) <-! combine-on-collection old-user, new-user, 'contacts', 'cid'

combine-strangers = !(old-user, new-user) ->
  old-user.contacted-strangers = util.union old-user.contacted-strangers, new-user.contacted-strangers
  old-user.contacted-by-strangers = util.union old-user.contacted-by-strangers, new-user.contacted-by-strangers

combine-mergences = !(old, _new, id-attr) ->
  _new.merged-to = old[id-attr]
  old.merged-from ||= []
  old.merged-from = util.union old.merged-from, _new.merged-from
  old.merged-from = util.union old.merged-from, _new.[id-attr]  
  if _new?.pending-merges?.length
    old-pending-merge-tos = [pm.pending-merge-to for pm in old.pending-merges when !pm.is-accepted and pm.pending-merge-to]
    old-pending-merge-froms = [pm.pending-merge-from for pm in old.pending-merges when !pm.is-accepted and pm.pending-merge-from]
    # console.log "\n\n*************** new.pending-merges: %j ***************\n\n", _new.pending-merges
    for pending-merge in _new?.pending-merges
      continue if pending-merge.is-accepted 
      if pending-merge.pending-merge-to and pending-merge.pending-merge-to not in old-pending-merge-tos and pending-merge.pending-merge-to is not old[id-attr]
        old.pending-merges.push {($C 'pending-merge-to'): pending-merge.pending-merge-to, ($C 'is-accepted'): false}
      if pending-merge.pending-merge-from  and pending-merge.pending-merge-from not in old-pending-merge-froms and pending-merge.pending-merge-from is not old[id-attr]
        old.pending-merges.push {($C 'pending-merge-from'): pending-merge.pending-merge-from, ($C 'is-accepted'): false}

add-pending-merges = !(old, _new, id-name) ->
  old.pending-merges ||= []
  old.pending-merges.push {($C 'pending-merge-to'): _new[id-name], ($C 'is-accepted'): false}
  _new.pending-merges ||= []
  _new.pending-merges.push {($C 'pending-merge-from'): old[id-name], ($C 'is-accepted'): false}


combine-contacts-names = !(old-contact, new-contact) ->
  old-contact.names = util.union old-contact.names, new-contact.names

combine-local-photo = !(old-contact, new-contact) ->
  old-contact.names = util.union old-contact.local-photos, new-contact.local-photos

combine-contacts-phones = !(old-contact, new-contact) ->
  old-contact.phones = util.union old-contact.phones, new-contact.phones

module.exports <<< info-combiner