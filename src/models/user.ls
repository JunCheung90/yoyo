/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', '../database', './Contact', './User-Merger']
require! common: './user-contact-common'

update-user = !(user, callback) ->
  # TODO：将save逻辑抽取到caller
  throw new Error "user: #{user.username} should be a persisted user!" if not user._id
  user-info-updated-handler user
  (err, result) <-! util.update-multiple-docs 'users', [user]
  callback!

create-user-with-contacts = !(user-data, callback)->
  # 如果系统中此用户尚未注册过，则新建user。
  user = {} <<< user-data
  build-user-basic-info user
  (old-user, new-user) <-! User-Merger.create-user-then-merge-with-existed-user user
  # 仅有new-user时，说明没有发现old-user需要合并；仅有old-user，说明user已经被合并到了old-user；new-user、old-user两者都有，说明发生了pending合并。
  contacts-owner = new-user or old-user # contacts将添加到的user是将新user识别为了old-user；仅有new-user是新建了一个独立的user
  perhaps-old-user = if old-user and new-user then old-user else null # 当new-user和old-user需要pending-merge时，会同时有两个users要存储。
  contacts-owner.uid ||= util.get-UUid!
  (to-create-users, to-update-users) <-! create-or-update-user-contacts contacts-owner
  <-! persist-all-users to-create-users, to-update-users, contacts-owner, perhaps-old-user 
  <-! get-api-keys contacts-owner
  callback contacts-owner

build-user-basic-info = !(user)->
  current = new Date!.get-time! 
  user.is-registered = true
  user.last-modified-date = current
  user.merged-to = null
  user.merged-from = []

  user.avatars = [create-default-system-avatar user] if not user?.avatar?.length
  user.current-avatar = user.avatars[0]
  [phone.start-using-time = current for phone in user.phones] if user?.phones?.length

create-default-system-avatar = (user) ->
  #TODO:
 
create-or-update-user-contacts = !(user, callback) ->
  if user.is-person ||= is-person user and user?.contacts?.length # 人类，有联系人
    (to-create-users, to-update-users) <-! Contact.create-contacts user # 联系人更新（识别为user，或创建为user）后，方回调。
    callback to-create-users, to-update-users
  else # 单位
    callback [], []

get-api-keys = !(user, callback) ->
  if user.is-person 
    async-get-api-keys user
    callback user
  else
    callback user

is-person = (user) ->
  # TODO: 判断用户是否是人，而不是单位。这里通过手机来注册，一般都是人类。
  true

persist-all-users = !(to-create-users, to-update-users, current-user, perhaps-old-user, callback) ->
  if current-user._id # is old user, need update
    to-update-users.push current-user 
  else
    to-create-users.push current-user
  to-update-users.push perhaps-old-user if perhaps-old-user
  (err, result) <-! util.update-multiple-docs 'users', to-update-users
  (err, result) <-! util.insert-multiple-docs 'users', to-create-users 
  throw new Error err if err
  callback!
  
async-get-api-keys = !(user)-> # 异步方法，完成之后会存储user。
  return if not user?.ims?.length
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

  db = database.get-db!
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

# user-info-updated-handler = !(user, time) ->
  #TODO:
  # db = database.get-db!
  # debugger
  # user.is-updated = true
  # console.log "用户#{user.name}的信息在#{time}发生了更新。"

(exports ? this) <<< {create-user-with-contacts, add-user-mergence-info, update-user, build-user-basic-info}