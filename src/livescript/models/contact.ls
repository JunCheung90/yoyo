/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './User-Merger']
require! fqh: '../fast-query-helper'
_ = require 'underscore'

create-contacts = !(db, owner, callback) ->
  owner.contacts-seq ||= 0
  to-create-contact-users = {}
  (err) <-! async.for-each owner.contacts, !(contact, next) -> # 为了性能异步并发
    (!(contact) ->
      contact.cid = create-cid owner.uid, ++owner.contacts-seq
      (old-user, new-user) <-! User-Merger.merge-contacts db, contact, owner, to-create-contact-users
      if old-user
        do
          <-! db.users.save old-user # 性能：现在为异步，可改为同步（性能会降低）。注意这里用了异步，可能会有数据一致性问题。
      to-create-contact-users[contact.cid] = new-user if new-user
      next!   
    )(contact)
  throw new Error err if err
  # 注意，这里在identify-and-bind-contact-as-user和create-contacts-users之间，有可能新的User来create contacts，
  # 其contacts中有和当前用户相同的user，因此会造成user的重复。所以今后必须有独立进程定期清理合并user。
  # Contact-Merger.merge-contacts user.contacts
  to-create-users = _.values to-create-contact-users
  clean-merge-to-and-from to-create-users
  clean-merge-to-and-from owner.contacts
  if to-create-users.length > 0 then
    (err, users) <-! db.users.insert to-create-users
    throw new Error err if err
    callback!  
  else
    callback! 

create-cid = (uid, seq-no) ->
  uid + '-c-' + new Date!.get-time! + '-' + seq-no

clean-merge-to-and-from = !(users) ->
# TODO：由于contacts是异步创建的，merge-to和from的关系会比较混乱，需要厘清

(exports ? this) <<< {create-contacts}