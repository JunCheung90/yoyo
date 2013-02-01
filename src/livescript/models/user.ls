/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './Contact']

create-user-with-contacts = !(db, user-data, callback)->
  # 如果系统中此用户尚未注册过，则新建user。
  user = {} <<< user-data
  build-user-basic-info user
  (user) <-! merge-same-users db, user
  <-! create-or-update-user-with-contacts db, user  
  callback user

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
 

merge-same-users = !(db, user, callback) -> # 目前只是merge一个非注册用户（通讯录中出现过、未注册的User）和一个将要注册的用户。今后将升级为merge其它情况。
  # TODO: 这里要更新为用fqi
  phones = [phone.phone-number for phone in user.phones]
  query-statement = # 目前只是检查电话和email的重复，来判断用户重复。今后可能引进规则引擎。
    $or:
      * "phones.phoneNumber": $in: phones
      * emails: $in: user.emails or []
  (err, users) <-! db.users.find(query-statement).toArray
  throw new Error err if err
  switch users.length
  case 0 then callback user # 0 为没有找到已存在的用户
  case 1 then # 1 为找到合并用户。这里的exist-user，以前并未注册，只是他人通讯录中出现过而已。
    exist-user = users[0] 
    throw new Error "User: #{user.name} is conflict with exist user: #{exist-user}. THE HANDLER LOGIC IS NOT IMPLEMENTED YET!" if exist-user.is-registered
    exist-user <<< user # 这里的exist-user，以前并未注册，只是他人通讯录中出现过而已。
    (err, result) <-! db.users.save exist-user
    throw new Error err if err
    callback exist-user
  default
    throw new Error "#{user-amount} exist users are similar with #{user.name}, THE LOGIC IS NOT IMPLEMENTED YET!" 

create-or-update-user-with-contacts = !(db, user, callback) ->
  user.as-contact-of ||= []
  user.contacted-strangers ||= []
  user.contacted-by-strangers ||= []  
  if user.is-person ||= is-person user # 人类
    <-! Contact.create-contacts db, user # 联系人更新（识别为user，或创建为user）后，方回调。
    (err, result) <-! db.users.save user
    throw new Error err if err
    async-get-api-keys db, user
    callback user
  else # 单位
    (err, result) <-! db.users.save user
    throw new Error err if err
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