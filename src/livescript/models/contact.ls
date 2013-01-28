/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! [async, '../util', './Contact-Merger']

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
  Contact-Merger.merge-contacts user.contacts

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