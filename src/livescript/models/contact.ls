require! [async, '../util']

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
  # 注意，这里在identify-and-bind-contact-as-user和create-contacts-users之间，有可能新的User来create contacts，
  # 其contacts中有和当前用户相同的user，因此会造成user的重复。所以今后必须有独立进程定期清理合并user。
  merge-contacts user.contacts

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
  contact.act-by-user = contact-user.uid
  contact-user.as-contact-of ||= []
  contact-user.as-contact-of.push owner.uid
  (err, result) <-! db.users.save contact-user
  throw new Error err if err
  callback!

merge-contacts = !(contacts) ->
  contacts-checked = []
  for contact in contacts
    uid = util.get-UUid!
    contact.act-by-user = util.get-UUid!
    check-and-merge-contacts contact, contacts-checked
    contacts-checked.push contact # TODO：多次合并的逻辑还没有厘清。


create-contacts-users = !(db, contacts, owner, callback) ->
  users = []
  for contact in contacts
    continue if contact.merged-to # 不论PENDING还是MERGED，被合并的用户只能创建一个用户。
    user = {}
    user{phones, emails, ims, sns} = contact # TODO：这里需要考虑contact的信息是否应当抽取到user。此时如果是PENDING merge，MERGED-FROM的信息没有抽取。
    user.uid = contact.act-by-user 
    user.is-registered = false
    user.as-contact-of ||= []
    user.as-contact-of.push owner.uid
    users.push user
  (err, users) <-! db.users.insert users
  throw new Error err if err
  callback!

create-cid = (uid, seq-no) ->
  uid + '-c-' + new Date!.get-time! + '-' + seq-no

(exports ? this) <<< {create-contacts} 

# --- ContactMerger ------- #
# TODO：这里复杂的合并逻辑还没有完成：1）
merge-strategy = require '../contacts-merging-strategy'
_ = require 'underscore' 

check-and-merge-contacts = !(contact-being-checked, contacts) ->
  for contact in contacts
    continue if contact.merged-to and !contact.is-merge-pending # 不会合并到已经被合并的用户
    switch should-contacts-be-merged contact, contact-being-checked
    case "NONE" then continue
    case "PENDING" then contact-being-checked.is-merge-pending = contact.is-merge-pending = true
    case "MERGED" then contact-being-checked.is-merge-pending = contact.is-merge-pending = false
    merge-two-contacts contact, contact-being-checked

should-contacts-be-merged = (c1, c2) ->
  # TODO：加载contacts-merging-strategy
  for key in merge-strategy.direct-merging
    if _.is-array c1[key] then
      return "MERGED" if !_.is-empty _.intersection c1[key], c2[key]
    else
      return "MERGED" if _.is-equal c1[key], c2[key]

  for key in merge-strategy.recommand-merging
    if _.is-array c1[key] then
      return "PENDING" if !_.is-empty _.intersection c1[key], c2[key]
    else
      return "PENDING" if _.is-equal c1[key], c2[key]

  "NONE"

merge-two-contacts = (c1, c2) -> # 返回null表示PENDING合并，没有真正合并内容；否则返回合并之后的Contact，整合所有信息到这个Contact。
  m-to = select-merge-to c1, c2 # 注意发现了与"PENDING"联系人相同的Cotact时，这里的m-to需要通盘考虑。
  m-from = if m-to.cid is c1.cid then c2 else c1
  m-to.merged-from ||= []
  m-to.merged-from.push m-from.cid
  m-from.merged-to = m-to.cid
  m-from.act-by-user = m-to.act-by-user

  if m-to.is-merge-pending then return null # "PENDING" 时，并不直接合并内容，而是等待用户处理后完成。
  for key in _.keys c1
    continue if key in ['cid', 'isMergePending', 'mergedTo', 'mergedFrom']
    if _.is-array c1[key] then
      m-to[key] = _.union m-to[key], m-from[key]
    else
      throw new Error "#{m-to.names} and #{m-from.names} contact merging CONFLICT for key: #{key}, with different value: #{m-to[key]}, #{m-from[key]}" if m-to[key] != m-from[key]

  m-to

select-merge-to = (c1, c2) ->
  c1 # TODO: 这里需要比较两个联系人的最后更新时间、最后联系时间、联系次数、等等进行确定。又或者和合并一样，需要外置规则。