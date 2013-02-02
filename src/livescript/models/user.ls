/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './Contact']
require! fqh: '../fast-query-helper'

create-user-with-contacts = !(db, user-data, callback)->
  # 如果系统中此用户尚未注册过，则新建user。
  user = {} <<< user-data
  build-user-basic-info user
  (existed-user, merged-user) <-! merge-same-users db, user
  <-! create-or-update-user-with-contacts db, merged-user  
  (err, result) <-! db.users.save merged-user
  throw new Error err if err
  db.users.save existed-user if existed-user # 注意：异步更新已有的user，不用等更新完成。可能会导致数据不一致的错误。
  if merged-user.is-person 
    async-get-api-keys db, merged-user
    callback merged-user
  else
    callback merged-user

build-user-basic-info = !(user)->
  current = new Date!.get-time!
  user.uid = util.get-UUid!
  user.is-registered = true
  user.last-modified-date = current
  user.is-merge-pending = false
  user.merge-to = null
  user.merge-from = []

  user.avatars = [create-default-system-avatar user] if not user?.avatar?.length
  user.current-avatar = user.avatars[0]
  [phone.start-using-time = current for phone in user.phones]

create-default-system-avatar = (user) ->
  #TODO:
 
# TODO：将这部分merge users的逻辑抽取到user-merger
merge-same-users = !(db, user, callback) -> 
  # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
  (existed-user, is-direct-merge) <-! fqh.get-existed-repeat-users db, user 
  if existed-user
    if is-direct-merge
      combine-users-info existed-user, user
      re-evaluate-user-pending-mergences db, existed-user if existed-user?.pending-merges?.length # 是否应该回调？
      callback null, existed-user # 彻底合并了，只需要更新一个user了。
    else
      existed-user.pending-merges ||= []
      existed-user.pending-merges.push {'pending-merge-from': user.uid, 'is-accepted': false}
      user.pending-merges ||= []
      user.pending-merges.push {'pending-merge-to': existed-user.uid, 'is-accepted': false}
      callback existed-user, user
  else
    callback null, user

combine-users-info = (old-user, new-user) ->
  # 这里的逻辑要更新，考虑各种复杂的信息合并情况。
  # 这里的exist-user，以前并未注册，只是他人通讯录中出现过而已。
  old-user <<< new-user

re-evaluate-user-pending-mergences = (db, existed-user) ->
  #TODO:
  console.log 'NOT IMPLEMENTED YET'

create-or-update-user-with-contacts = !(db, user, callback) ->
  user.as-contact-of ||= []
  user.contacted-strangers ||= []
  user.contacted-by-strangers ||= []  
  if user.is-person ||= is-person user # 人类
    <-! Contact.create-contacts db, user # 联系人更新（识别为user，或创建为user）后，方回调。
    callback user
  else # 单位
    callback user

is-person = (user) ->
  # TODO: 判断用户是否是人，而不是单位。这里通过手机来注册，一般都是人类。
  true

async-get-api-keys = !(db, user)-> # 异步方法，完成之后会存储user。
  (err) <-! async.for-each user.ims, !(im, next) ->
    (api-key) <-! async-get-im-api-key im
    im.api-key = api-key
    next!
  throw new Error err if err

  (err) <-! async.for-each user.sns, !(sn, next) ->
    (api-key) <-! async-get-sn-api-key sn
    sn.api-key = api-key
    next!
  throw new Error err if err

  (err, user) <-! db.users.save user
  throw new Error err if err

async-get-im-api-key = !(im, callback) ->
  # TODO: 
  callback!

async-get-sn-api-key = !(sn, callback) ->
  # TODO: 
  callback!

(exports ? this) <<< {create-user-with-contacts}  