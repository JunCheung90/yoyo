# 这里的map以相应的phone、email、sns、im为key，uid为value。用于快速判断和查找某种通讯方式是否已经使用。
# 服务器启动时，先从mongoDB中读取并初始化这些map，在程序执行中，需要在新建user（contact）时，更新这部分的内容。
_ = require 'underscore'
require! './database'

fqh =
  user-phone-map: {}
  user-email-map: {}
  user-sn-map: {}
  user-im-map: {}

  init-communication-channels-maps: (callback)->
    db = database.get-db!
    db.users.find {}, (err, cursor)->
      throw new Error err if err
      cursor.each (err, user)->
        throw new Error err if err
        # console.log "********** user: %j ************", user
        # fqh.update user
    callback!

  update: !(user)->
    fqh.add-phone-to-map user if user.phones
    fqh.add-email-to-map user if user.emails
    fqh.add-sn-to-map user if user.sns
    fqh.add-im-to-map user if user.ims


  add-phone-to-map: !(user) ->
    _map = fqh.user-phone-map
    for phone in user.phones
      number = phone.phone-number
      if _map[number] 
          _map[number].push user.uid 
      else
        _map[number] = [user.uid]

  add-email-to-map: !(user) ->
    _map = fqh.user-email-map
    for email in user.emails
      if _map[email] 
          _map[email].push user.uid 
      else
        _map[email] = [user.uid]

  add-sn-to-map: !(user) ->
    _map = fqh.user-sn-map
    for sn in user.sns
      sn-str = sn.account + '@' + sn.type
      if _map[sn-str] 
          _map[sn-str].push user.uid 
      else
        _map[sn-str] = [user.uid]

  add-im-to-map: !(user, _map) ->
    _map = fqh.user-im-map
    for im in user.ims
      im-str = im.account + '@' + im.type
      if _map[im-str] 
          _map[im-str].push user.uid 
      else
        _map[im-str] = [user.uid]

  get-existed-repeat-user: !(user, callback) ->
    phones = []
    phones = [phone.phone-number for phone in user.phones] if user?.phones?.length
    emails = user.emails or []
    (users) <-! fqh.query-users-on-phone-and-email phones, emails
    throw new Error "#{users.length} existed repeat users found." if users.length > 1 and are-not-pending-merge-together users
    is-direct-merge = true
    callback users[0], is-direct-merge

  query-users-on-phone-and-email: !(phones, emails, callback) ->
    query-statement = # 目前只是检查电话和email的重复，来判断用户重复。今后可能引进规则引擎。
      $or:
        * "phones.phoneNumber": $in: phones
        * "emails": $in: emails
        # not merged-to 补充这个条件
    db = database.get-db!
    (err, users) <-! db.users.find(query-statement).toArray
    throw new Error err if err
    callback users
    

  get-existed-contact-users: (contact, callback) ->
    phones = contact.phones or []
    emails = contact.emails or []
    (users) <-! fqh.query-users-on-phone-and-email phones, emails
    callback users

are-not-pending-merge-together = (users) ->
  # TODO: 判断出这里的users没有pending合并到一起
  false

module.exports = fqh 