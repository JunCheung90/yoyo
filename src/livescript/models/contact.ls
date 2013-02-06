/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './Contact-Merger']
require! common: './user-contact-common'
_ = require 'underscore'

# ！！！注意，在async-create-unsaved-contacts-users和save-contacts-users之间，有可能新的User来create contacts，
# 其contacts中有和当前用户相同的user，因此会造成user的重复。所以今后必须有独立进程定期清理合并user。
create-contacts = !(db, contacts-owner, callback) ->
  (to-create-users, to-update-users) <-! async-create-unsaved-contacts-users db, contacts-owner
  # 异步create时，判断merge-to和merge-from会有问题，需要整理。
  clean-merge-to-and-from contacts-owner.contacts 
  clean-merge-to-and-from to-create-users
  # <-! save-contacts-users db, to-create-users
  # <-! update-contacts-users db, to-update-users
  callback to-create-users, to-update-users

async-create-unsaved-contacts-users = !(db, owner, callback) ->
  owner.contacts-seq ||= 0
  to-create-contact-users-map = {}
  to-update-contact-users-map = {}
  (err) <-! async.for-each owner.contacts, !(contact, next) -> # 为了性能异步并发
    (!(contact) -> create-contact-THEN-merge-its-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner \
      db, contact, owner, to-create-contact-users-map, to-update-contact-users-map, next
    )(contact)
  throw new Error err if err
  to-create-users = _.values to-create-contact-users-map
  to-update-users = _.values to-update-contact-users-map
  callback to-create-users, to-update-users

create-contact-THEN-merge-its-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner = \
(db, contact, owner, to-create-contact-users, to-update-contact-users-map, callback) ->
  contact.cid = create-cid owner.uid, ++owner.contacts-seq
  (old-contact-user, new-contact-user) <-! Contact-Merger.merge-contact-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner \
  db, contact, owner, to-create-contact-users

  if old-contact-user # contact的act-by-user被识别（合并）为已有user，因此需要更新已有user（其as-contact-of）发生了变化。
    do
      <-! db.users.save old-contact-user # 性能：现在为异步，可改为同步（性能会降低）。注意这里用了异步，可能会有数据一致性问题。
  to-create-contact-users[contact.cid] = new-contact-user if new-contact-user
  callback!   

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
  user.as-contact-of = _.union user.as-contact-of, owner.uid

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
create-contact-user, bind-contact-with-user}