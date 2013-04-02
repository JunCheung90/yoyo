/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', '../mergence/Contact-Merger', './Users']
require! common: '../mergence/user-contact-common', Validator: './helpers/communication-channel-validator'

Contacts =
  # ！！！注意，在async-create-unsaved-contacts-users和save-contacts-users之间，有可能新的User来create contacts，
  # 其contacts中有和当前用户相同的user，因此会造成user的重复。所以今后必须有独立进程定期清理合并user。
  create-contacts: !(contacts-owner, callback) ->
    (to-create-users, to-update-users) <-! async-create-unsaved-contacts-users contacts-owner
    remove-contacts-volatile-pending-merges contacts-owner.contacts #volatile-pending-merges是需要pending merge的contact对象的引用，持久化前要去除。
    # 异步create时，判断merge-to和merge-from会有问题，需要整理。
    clean-merge-to-and-from contacts-owner.contacts 
    clean-merge-to-and-from to-create-users
    callback to-create-users, to-update-users

  bind-contact-with-user: !(contact, user, owner) ->
    contact.act-by-user = user.uid
    user.as-contact-of ||= [] 
    user.as-contact-of = util.union user.as-contact-of, owner.uid

  add-contact-mergence-info: !(old-contact, new-contact) ->
    common.add-mergence-info old-contact, new-contact, 'cid'

  # volatile pending merge用来帮助生成对应的user，并加上pending merge。在持久化时必须去掉。
  add-volatile-pending-merge: !(source, distination) ->
    source.__pending-merges ||= [] 
    distination.__pending-merges ||= []
    source.__pending-merges.push {($C 'pending-merge-to'): distination}
    distination.__pending-merges.push {($C 'pending-merge-from'): source}

  remove-invalid-contacts: !(contacts-owner) ->
    if contacts-owner?.contacts?.length
      contacts-owner.contacts = filter is-valid-contact, contacts-owner.contacts

  create-cid: (uid, seq-no) ->
    uid + '-c-' + new Date!.get-time! + '-' + seq-no

  update-contact: (old-contact, new-profile) ->
    for key, value of new-profile
      if key in profile-filter!
        old-contact[key] = value
    old-contact

profile-filter = ->
  ['phones', 'emails', 'ims', 'sns', 'tags', 'addresses']


async-create-unsaved-contacts-users = !(owner, callback) ->
  to-create-contact-users = []
  to-update-contact-users = []
  create-and-merge-contacts-before-create-users owner, owner.contacts
  merged-contacts = get-merged-contacts owner.contacts
  contact-user-creator = contact-user-creator-factory!
  (err) <-! async.for-each merged-contacts, !(contact, next) -> # 为了性能异步并发
    (!(contact) -> merge-contact-act-by-user-with-existed-users \
      contact, owner, to-create-contact-users, to-update-contact-users, contact-user-creator, next
    )(contact)
  throw new Error err if err
  callback to-create-contact-users, to-update-contact-users

get-merged-contacts = (contacts) ->
  if contacts?.length
    merged-contacts = filter (-> !it.merged-to), contacts 
  else
    merged-contacts = []

merge-contact-act-by-user-with-existed-users = \
(contact, owner, to-create-contact-users, to-update-contact-users, contact-user-creator, callback) ->
  contact-user = create-contact-user contact, contact-user-creator
  (old-contact-user, new-contact-user) <-! Contact-Merger.merge-contact-act-by-user-with-existed-users contact, contact-user, owner
  to-update-contact-users.push old-contact-user if old-contact-user
  to-create-contact-users.push new-contact-user if new-contact-user
  callback!   

create-and-merge-contacts-before-create-users = (owner, contacts) ->
  Contact-Merger.merge-contacts owner, contacts

clean-merge-to-and-from = !(users) ->
# TODO：由于contacts是异步创建的，merge-to和from的关系会比较混乱，需要厘清

$C = util.to-camel-case 
create-contact-user = (contact, contact-user-creator) ->
  user = contact-user-creator contact
  if has-volatile-pendign-merge contact
    user.pending-merges ||= []
    for p in contact.__pending-merges
      if p.pending-merge-to
        user-p-to = contact-user-creator p.pending-merge-to
        user-p-to.pending-merges ||= []
        user.pending-merges.push {($C 'pending-merge-to'): user-p-to.uid, ($C 'is-accepted'): false}
        user-p-to.pending-merges.push {($C 'pending-merge-from'): user.uid, ($C 'is-accepted'): false}
  user

contact-user-creator-factory = -> 
  contact-user-map = {}
  (contact) ->
    user = contact-user-map[contact.cid]
    if !user
      user = {} <<< contact{emails, ims, sns}
      Users.build-user-basic-info user
      user.uid = util.get-UUid! 
      user.is-registered = false
      user.nicknames = contact.names
      if contact?.phones?.length
        user.phones = []
        for phone in contact.phones
          user.phones.push {phone-number: phone}
      contact-user-map[contact.cid] = user
    user

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

remove-contacts-volatile-pending-merges = !(contacts) ->
  for contact in contacts
    remove-volatile-pending-merge contact

remove-volatile-pending-merge = !(contact) ->
  delete contact.__pending-merges

has-volatile-pendign-merge = (contact) ->
  contact?.__pending-merges?.length

is-valid-contact = ->
  Validator.has-valid-phones it.phones or
  Validator.has-valid-emails it.emails or
  Validator.has-valid-sns it.sns or
  Validator.has-valid-ims it.ims

module.exports <<< Contacts
