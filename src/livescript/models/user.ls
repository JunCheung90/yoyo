require! [async, '../util']

create-user-with-contacts = !(db, user-data, callback)->
  # 
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
  user.merge-status = 'NONE'
  user.merge-to = null
  user.merge-from = []

  user.avatars = [create-default-system-avatar user] if not user?.avatar?.length
  user.current-avatar = user.avatars[0]
  [phone.start-using-time = current for phone in user.phones]

create-default-system-avatar = (user) ->
  #TODO:
 

merge-same-users = !(db, user, callback) ->
  phones = [phone.phone-number for phone in user.phones]
  query-statement = 
    $or:
      * "phones.phoneNumber": $in: phones
      * emails: $in: user.emails or []
      ...
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
    throw new Error "#{user-amount} exist users are similar with #{user.name}, THE LOGIC IS NOT IMPLEMENTED YET!" if user-amount > 1

# find-similar-users = !(db, user-or-contact, callback) ->
#   if user-or-contact.contacts # 只有user才有contacts

create-or-update-user-with-contacts = !(db, user, callback) ->
  user.as-contact-of ||= []
  user.contacted-strangers ||= []
  user.contacted-by-strangers ||= []  
  if user.is-person ||= is-person user # 人类
    <-! create-contacts db, user # 联系人更新（识别为user，或创建为user）后，方回调。
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

create-contacts = !(db, user, callback) ->
  user.contacts-seq ||= 0
  to-create-contact-users = []
  (err) <-! async.for-each user.contacts, !(contact, next) -> # 为了性能异步并发
    (!(contact) ->
        contact.cid = create-cid user.uid, ++user.contacts-seq
        (contact-user-amount) <-! identify-and-bind-contact-as-user db, contact, user
        throw new Error "#{contact} refers to more than one user: #{contact-user}" if contact-user-amount > 1
        to-create-contact-users.push contact if contact-user-amount is 0
        next!   
    )(contact)
  throw new Error err if err
  if to-create-contact-users.length > 0 then
    <-! create-contacts-users db, to-create-contact-users, user   
    callback!
  else
    callback!

identify-and-bind-contact-as-user = !(db, contact, owner, callback) -> # 回调返回找到并bind的用户个数。如果找到唯一用户，则将contact bind到这个用户上。
  # TODO: 需要处理各种情况：1）电话号码相同也有可能不是同一个人（换电话了）；2）email比较肯定，很少会换；
  # 3）im会换；4）sn不清楚；5）这里还有数据本身有错误，用户记错了或在手机端处理时有错的情况，例如：将电话号码记错一位，少记一位等等。
  # 考虑使用规则引擎。
  query-statement = 
    $or:
      * "phones.phoneNumber": $in: contact.phones or []
      * emails: $in: contact.emails or []
      ...
  (err, contact-users) <-! db.users.find(query-statement).toArray
  throw new Error err if err
  contact-user-amount = contact-users?.length or 0
  switch contact-user-amount
  case 0 then callback 0 # 没有找到已存在的用户
  case 1 then  
    <-! bind-contact db, contact, contact-users[0], owner # 性能考虑：这里可以考虑改为不用同步，直接就callback了，不等bind-contact。
    callback 1
  default callback contact-user-amount

bind-contact = !(db, contact, contact-user, owner, callback) -> 
  debugger
  contact.uid = contact-user.uid
  contact-user.as-contact-of ||= []
  contact-user.as-contact-of.push owner.uid
  (err, result) <-! db.users.save contact-user
  throw new Error err if err
  callback!

create-contacts-users = !(db, contacts, owner, callback) ->
  users = []
  for contact in contacts
    user = {}
    user{phones, emails, ims, sns} = contact # TODO：这里需要考虑contact的信息是否应当抽取到user。
    contact.uid = user.uid = util.get-UUid!
    user.is-registered = false
    user.as-contact-of ||= []
    user.as-contact-of.push owner.uid
    users.push user
  (err, users) <-! db.users.insert users
  throw new Error err if err
  callback!

create-cid = (uid, seq-no) ->
  uid + '-c-' + new Date!.get-time! + '-' + seq-no

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