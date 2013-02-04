/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './Contact', './User-Merger']

create-user-with-contacts = !(db, user-data, callback)->
  # 如果系统中此用户尚未注册过，则新建user。
  user = {} <<< user-data
  build-user-basic-info user
  (old-user, new-user) <-! User-Merger.merge-same-users db, user
  merged-user = new-user or old-user # 仅有old-user，是将新user识别为了old-user；仅有new-user是新建了一个独立的user
  <-! create-or-update-user-contacts db, merged-user  
  (err, result) <-! db.users.save merged-user
  throw new Error err if err
  db.users.save old-user if old-user and new-user # 当new-user和old-user需要pending-merge时，两个users都要存储。
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
 
create-or-update-user-contacts = !(db, user, callback) ->
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