/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './Contact-Merger']
require! common: './user-contact-common'

# ！！！注意，在async-create-unsaved-contacts-users和save-contacts-users之间，有可能新的User来create contacts，
# 其contacts中有和当前用户相同的user，因此会造成user的重复。所以今后必须有独立进程定期清理合并user。
create-contacts = !(db, contacts-owner, callback) ->
  (to-create-users, to-update-users) <-! async-create-unsaved-contacts-users db, contacts-owner
  # 异步create时，判断merge-to和merge-from会有问题，需要整理。
  clean-merge-to-and-from contacts-owner.contacts 
  clean-merge-to-and-from to-create-users
  callback to-create-users, to-update-users

async-create-unsaved-contacts-users = !(db, owner, callback) ->
  to-create-contact-users = []
  to-update-contact-users = []
  create-and-merge-contacts-before-create-users owner, owner.contacts
  merged-contacts = filter (-> !it.merged-to), owner.contacts
  (err) <-! async.for-each merged-contacts, !(contact, next) -> # 为了性能异步并发
    (!(contact) -> merge-contact-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner \
      db, contact, owner, to-create-contact-users, to-update-contact-users, next
    )(contact)
  throw new Error err if err
  callback to-create-contact-users, to-update-contact-users

merge-contact-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner = \
(db, contact, owner, to-create-contact-users, to-update-contact-users, callback) ->
  (old-contact-user, new-contact-user) <-! Contact-Merger.merge-contact-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner db, contact, owner
  to-update-contact-users.push old-contact-user if old-contact-user
  to-create-contact-users.push new-contact-user if new-contact-user
  callback!   

create-and-merge-contacts-before-create-users = (owner, contacts) ->
  Contact-Merger.merge-contacts owner, contacts


create-cid = (uid, seq-no) ->
  uid + '-c-' + new Date!.get-time! + '-' + seq-no

clean-merge-to-and-from = !(users) ->
# TODO：由于contacts是异步创建的，merge-to和from的关系会比较混乱，需要厘清

add-contact-mergence-info = (old-contact, new-contact) ->
  common.add-mergence-info old-contact, new-contact, 'cid'

create-contact-user = (contact) ->
  user = {} <<< contact{emails, ims, sns}
  user.uid = util.get-UUid! 
  user.is-registered = false
  user.nicknames = contact.names
  if contact?.phones?.length
    user.phones = []
    for phone in contact.phones
      user.phones.push {phone-number: phone}
  user

bind-contact-with-user = !(contact, user, owner) ->
  contact.act-by-user = user.uid
  user.as-contact-of ||= [] 
  user.as-contact-of = util.union user.as-contact-of, owner.uid

get-merge-to-contact = (contacts, contact, is-direct-merge) ->
  act-by-user = contact.act-by-user
  if contacts?.length
    for c in contacts
      if c.cid != contact.cid and c.act-by-user is act-by-user
        return get-final-merged-to contacts, c 
  else
    null

get-final-merged-to = (contacts, contact) ->
  return contact if !contact.merged-to
  while contact.merged-to
    contact = get-contact contacts, contact.merged-to

get-contact = (contacts, cid) ->
  for contact in contacts
    return contact if contact.cid is cid

(exports ? this) <<< \
{create-contacts, add-contact-mergence-info, get-merge-to-contact,
create-contact-user, bind-contact-with-user, create-cid}