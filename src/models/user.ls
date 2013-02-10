/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './Contact', './User-Merger']
require! common: './user-contact-common'

create-user-with-contacts = !(db, user-data, callback)->
  # 如果系统中此用户尚未注册过，则新建user。
  user = {} <<< user-data
  build-user-basic-info user
  (old-user, new-user) <-! User-Merger.create-user-then-merge-with-existed-user db, user
  # 仅有new-user时，说明没有发现old-user需要合并；仅有old-user，说明user已经被合并到了old-user；new-user、old-user两者都有，说明发生了pending合并。
  contacts-owner = new-user or old-user # contacts将添加到的user是将新user识别为了old-user；仅有new-user是新建了一个独立的user
  perhaps-old-user = if old-user and new-user then old-user else null # 当new-user和old-user需要pending-merge时，会同时有两个users要存储。
  contacts-owner.uid ||= util.get-UUid!
  (to-create-users, to-update-users) <-! create-or-update-user-contacts db, contacts-owner
  <-! persist-all-users db, to-create-users, to-update-users, contacts-owner, perhaps-old-user 
  <-! get-api-keys db, contacts-owner
  callback contacts-owner

build-user-basic-info = !(user)->
  current = new Date!.get-time!
  user.is-registered = true
  user.last-modified-date = current
  user.merge-to = null
  user.merge-from = []

  user.avatars = [create-default-system-avatar user] if not user?.avatar?.length
  user.current-avatar = user.avatars[0]
  [phone.start-using-time = current for phone in user.phones]

create-default-system-avatar = (user) ->
  #TODO:
 
create-or-update-user-contacts = !(db, user, callback) ->
  if user.is-person ||= is-person user # 人类
    (to-create-users, to-update-users) <-! Contact.create-contacts db, user # 联系人更新（识别为user，或创建为user）后，方回调。
    callback to-create-users, to-update-users
  else # 单位
    callback null, null

get-api-keys = !(db, user, callback) ->
  if user.is-person 
    async-get-api-keys db, user
    callback user
  else
    callback user

is-person = (user) ->
  # TODO: 判断用户是否是人，而不是单位。这里通过手机来注册，一般都是人类。
  true

persist-all-users = !(db, to-create-users, to-update-users, current-user, perhaps-old-user, callback) ->
  if current-user._id # is old user, need update
    to-update-users.push current-user 
  else
    to-create-users.push current-user
  to-update-users.push perhaps-old-user if perhaps-old-user
  (err, result) <-! util.update-multiple-docs db, 'users', to-update-users
  (err, result) <-! util.insert-multiple-docs db, 'users', to-create-users 
  throw new Error err if err
  callback!
  
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

add-user-mergence-info = (old-user, new-user) ->
  common.add-mergence-info old-user, new-user, 'uid'


(exports ? this) <<< {create-user-with-contacts, add-user-mergence-info}  