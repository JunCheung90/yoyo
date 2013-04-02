# 这里的map以相应的phone、email、sns、im为key，uid为value。用于快速判断和查找某种通讯方式是否已经使用。
# 服务器启动时，先从mongoDB中读取并初始化这些map，在程序执行中，需要在新建user（contact）时，更新这部分的内容。
_ = require 'underscore'
require! './database'

qh =
  get-existed-repeat-user: !(user, callback) ->
    # TODO：重构，此处逻辑需要好好厘清，效率也需要提升。
    (users) <-! @get-repeat-users user
    throw new Error "#{users.length} existed repeat users found." if users.length > 1 and are-not-pending-merge-together users
    is-direct-merge = true
    callback users[0], is-direct-merge

  get-repeat-users: !(user, callback) ->
    # TODO：重构，此处逻辑需要好好厘清，效率也需要提升。
    # 目前只是检查电话和email的重复，来判断用户重复。今后可能引进规则引擎。
    phones = []
    phones = [phone.phone-number for phone in user.phones] if user?.phones?.length
    emails = user.emails or []
    (users) <-! query-users-on-phone-and-email phones, emails
    users = filter (.uid isnt user.uid), users if user.uid # TODO：性能：应该重构到查询条件中。
    callback users

  get-users-by-uids: !(uids, callback) ->
    query-statement =
      "uid": $in: uids
    query-database-for-users query-statement, callback

  get-existed-contact-users: !(contact, callback) ->
    phones = contact.phones or []
    emails = contact.emails or [] 
    (users) <-! query-users-on-phone-and-email phones, emails
    callback users

query-users-on-phone-and-email = !(phones, emails, callback) ->
  query-statement = 
    $or:
      * "phones.phoneNumber": $in: phones
      * "emails": $in: emails
      # not merged-to 补充这个条件
  query-database-for-users query-statement, callback

query-database-for-users = !(query-statement, callback) ->
  (db) <-! database.get-db
  (err, users) <-! db.users.find(query-statement).toArray
  throw new Error err if err
  callback users
    


are-not-pending-merge-together = (users) ->
  # TODO: 判断出这里的users没有pending合并到一起
  false

module.exports <<< qh 