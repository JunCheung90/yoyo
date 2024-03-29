/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', '../db/database']
require! common: '../mergence/user-contact-common', qh: '../db/query-helper', Contacts: './contacts', User-Merger: '../mergence/user-merger'

Users =
  create-user-with-contacts: !(user-data, callback)->
    # 如果系统中此用户尚未注册过，则新建user。
    user = {} <<< user-data
    @build-user-basic-info user
    Contacts.remove-invalid-contacts user # TODO：性能：可以合并到Contacts.create-contacts的循环中。
    (old-user, new-user) <-! User-Merger.create-user-then-merge-with-existed-user user
    # 仅有new-user时，说明没有发现old-user需要合并；仅有old-user，说明user已经被合并到了old-user；new-user、old-user两者都有，说明发生了pending合并。
    contacts-owner = new-user or old-user # contacts将添加到的user是将新user识别为了old-user；仅有new-user是新建了一个独立的user
    perhaps-old-user = if old-user and new-user then old-user else null # 当new-user和old-user需要pending-merge时，会同时有两个users要存储。
    contacts-owner.uid ||= util.get-UUid!
    (to-create-users, to-update-users) <-! create-or-update-user-contacts contacts-owner
    # TODO：今后将抽取到Controller里面予以协调。
    ranking-contacts-mining-interesting-info-and-set-avatar contacts-owner
    <-! persist-all-users to-create-users, to-update-users, contacts-owner, perhaps-old-user 
    <-! get-api-keys contacts-owner
    callback contacts-owner

  update-user-profile: !(user-new-profile, callback) ->
    (err, user) <-! @get-user-by-uid user-new-profile.uid
    callback err, null if err
    (err) <-! update-each-new-profile user, user-new-profile
    callback err, null if err
    (err) <-! update-each-as-contacts user, user-new-profile
    callback err, null if err
    callback null, user

  get-user-by-uid: !(uid, callback) ->
    err = null
    (users) <-! qh.get-users-by-uids [uid]
    err = new Error "can not find user with uid: #user-new-profile.uid" if users.length == 0
    callback err, users[0]    

  mining-interesting-info: !(user, callback) ->
    callback!

  build-user-basic-info: !(user)->
    current = new Date!.get-time! 
    user.is-registered = true
    user.last-modified-date = current
    user.merged-to = null
    user.merged-from = []

    user.avatars = [create-default-system-avatar user] if not user?.avatar?.length
    user.current-avatar = user.avatars[0]
    [phone.start-using-time = current for phone in user.phones] if user?.phones?.length

  get-or-create-user-with-phone-number: !(phone-number, callback) ->
    (user) <-! get-user-with-phone-number phone-number
    if user
      callback user 
    else
      (user) <-! create-user-with-phone-number phone-number
      callback user

  update-user-contacted-strangers: !(user-uid, stranger-uid, callback) ->
    /**
    
      TODO:
      - add stranger to user.contacted-strangers
    
    **/
    callback!

  update-user-contacted-by-strangers: !(user-uid, stranger-uid, callback) ->
    /**
    
      TODO:
      - add stranger if it's stranger
    
    **/
    callback!

  update-user-contacts: !(contacts-owner, callback) ->
    (to-create-users, to-update-users) <-! create-or-update-user-contacts contacts-owner
    # TODO：今后将抽取到Controller里面予以协调。
    ranking-contacts-mining-interesting-info-and-set-avatar contacts-owner
    <-! persist-all-users to-create-users, to-update-users, contacts-owner, null
    callback contacts-owner

  update-user-sn-api-key: !(uid, new-sn, callback) ->
    (err, user) <-! @get-user-by-uid uid
    callback err if err
    user.sns ?= []
    for sn in user.sns
      if sn.type == new-sn.type
        sn = new-sn
        callback!
    user.sns.push new-sn
    (err, result) <-! util.update-multiple-docs 'users', [user]
    callback!


update-each-new-profile = !(user, user-new-profile, callback) ->
  for key, value of user-new-profile
    user[key] = value if value is not null
  user.last-modified-date = new Date!.get-time!
  (err, result) <-! util.update-multiple-docs 'users', [user]  
  callback err

update-each-as-contacts = !(user, user-new-profile, callback) ->
  as-contacts = user.as-contact-of
  as-contacts ?= []
  relative-users = []
  (err) <-! async.for-each as-contacts, !(as-contact, next) ->
    (err, user-has-contact) <-! Users.get-user-by-uid as-contact
    for contact in user-has-contact.contacts
      if contact.act-by-user == user.uid
        Contacts.update-contact contact, user-new-profile
        break
    relative-users.push user-has-contact  
    next!
  throw new Error err if err
  (err, result) <-! util.update-multiple-docs 'users', relative-users
  callback err

get-user-with-phone-number = !(phone-number, callback) ->
  #TODO: 
  (users) <-! qh.get-existed-users-on-phones [phone-number]
  if users.length > 0
    callback users[0]
  else
    callback null

create-user-with-phone-number = !(phone-number, callback) ->
  #TODO:  
  user = {
    phones: {
      phone-number: phone-number
      is-active: true
      start-using-time: new Date!.get-time!
    }
  }
  Users.build-user-basic-info user
  user.is-registered = false
  user.uid = util.get-UUid!
  (result) <-! util.save-new-data 'users', user
  callback result

create-default-system-avatar = (user) ->
  #TODO:
 
create-or-update-user-contacts = !(user, callback) ->
  if user.is-person ||= is-person user and user?.contacts?.length # 人类，有联系人
    (to-create-users, to-update-users) <-! Contacts.create-contacts user # 联系人更新（识别为user，或创建为user）后，方回调。
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

  # donothing, api-key改由客户端维护，当有变改的时候通知服务端修改
  # (err) <-! async.for-each user.sns, !(sn, next) ->
  #   (api-key) <-! async-get-sn-api-key sn
  #   sn.api-key = api-key
  #   next!
  # throw new Error err if err

  (db) <-! database.get-db
  (err, user) <-! db.users.save user
  throw new Error err if err

async-get-im-api-key = !(im, callback) ->
  # TODO: 
  callback!

async-get-sn-api-key = !(sn, callback) ->
  # TODO: 
  callback!

ranking-contacts-mining-interesting-info-and-set-avatar = !(contacts-owner) ->
  # TODO：执行后，contacts-owner的每个contact将会有rank-score，用于排名。挖掘有趣信息和确定头像的工作同时进行。contacts-owner（user）将有interesting-infos


module.exports <<< Users