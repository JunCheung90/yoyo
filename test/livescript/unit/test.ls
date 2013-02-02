/*
 * Created by Wang, Qing. All rights reserved.
 */
 
require! ['should', 'async', 
          '../../src/models/User',
          '../../src/servers-init'.init-mongo-client, 
          '../../src/servers-init'.shutdown-mongo-client,
          '../../src/util']

_ = require 'underscore'
fqi = require '../../src/fast-query-index'

[db, client] = [null null]

multiple-times = 100

repeat-rate = 0.2

can = it # it在LiveScript中被作为缺省的参数，因此我们先置换为can

describe 'mongoDb版注册用户：识别用户，绑定用户（User）和联系人（Contact）', !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users' 
    <- fqi.init-communication-channels-maps db
    done! 

  can '创建User张三，张三有2个Contacts，作为0人的Contact。\n', !(done) ->
    <-! create-and-check-user 'zhangsan.json', '张三'
    check-user-contacts '张三', 2, 0, done

  can '创建User李四，李四有2个Contacts，作为1人的Contact。\n', !(done) ->
    <-! create-and-check-user 'lisi.json', '李四'
    check-user-contacts '李四', 2, 1, done 


  can '创建User赵五，赵五有3个Contacts，作为2人的Contacts。\n', !(done) ->
    <-! create-and-check-user 'zhaowu.json', '赵五' 
    check-user-contacts '赵五', 3, 2, done


  can '最新张三联系人情况，有2个Contacts，作为2人的Contacts。\n' !(done) ->
    check-user-contacts '张三', 2, 2, done 

  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!

describe 'mongoDb版注册用户：简单合并联系人', !->
  do
    (done) <-! before
    (mongo-client, mongo-db) <-! init-mongo-client
    [db, client] := [mongo-db, mongo-client]
    <-! db.drop-collection 'users'
    <- fqi.init-communication-channels-maps db
    done! 

  all-original-contacts = 3 # zhaowu.json中有3个联系人，2个不重复。
  non-repeat-original-contacts = 2 # zhaowu.json中有3个联系人，2个不重复。
 
  can '创建User赵五。赵五的联系人两个Contacts（张大三、张老三）合并为一。\n', !(done) ->
    <-! create-and-check-user 'zhaowu.json', '赵五'
    (err, found-users) <-! db.users.find({'name': '赵五'}).to-array
    found-users.length.should.eql 1
    <-! are-contacts-merged-correct found-users[0].contacts, non-repeat-original-contacts
    (err, all-users) <-! db.users.find().to-array
    all-users.length.should.eql 3
    done!


  can '对多个重复联系人正确合并。\n', !(done) ->
    # 在初始数据的基础上，随机生成多个重复联系人，然后能够正确合并。
    <-! db.drop-collection 'users' # 不要重复创建赵五这个联系人。
    (non-repeat-contacts-amount) <-! create-and-check-user-with-mulitple-repeat-contacts 'zhaowu.json', '赵五'
    (err, found-users) <-! db.users.find({'name': '赵五'}).to-array
    found-users.length.should.eql 1
    found-users[0].contacts.length.should.eql all-original-contacts + multiple-times
    <-! are-contacts-merged-correct found-users[0].contacts, non-repeat-original-contacts + non-repeat-contacts-amount
    # (err, all-users) <-! db.users.find().to-array
    # all-users.length.should.eql 3
    done!


  do
    (done) <-! after 
    <-! shutdown-mongo-client client
    done!

create-and-check-user = !(json-file-name, user-name, callback) ->
  # 这里用require，会导致第二次load json时，直接用的是缓存，而不是重新load！！
  user-data = util.load-json __dirname + "/../test-data/#{json-file-name}"
  (user) <-! User.create-user-with-contacts db, user-data
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-users[0].name.should.eql user-name
  console.log "\n\t成功创建了User：#{found-users[0].name}"
  callback! 

check-user-contacts = !(user-name, amount-of-has-contacts, amount-of-as-contacts, callback) ->
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-user = found-users[0]
  found-user.contacts.length.should.eql amount-of-has-contacts
  # console.log "\n\t找回的User：#{user-name}有#{found-user.contacts.length}个联系人：%j", [[name for name in contact.names] for  contact in found-user.contacts]

  found-user.as-contact-of.length.should.eql amount-of-as-contacts
  console.log "\n\t找回的User：#{user-name}作为#{found-user.as-contact-of.length}个联系人"

  console.log "\n\t找回的User：#{user-name}有#{found-user.sns.length}个SN：%j" [{sn.sn-name, sn.account-name} for sn in found-user.sns]

  callback!      

are-contacts-merged-correct = !(contacts, non-repeat-contacts-amount, callback) ->
  # show-contacts contacts
  merged-result-contacts = filter is-merged-result-contact, contacts
  # show-contacts merged-result-contacts
  merged-result-contacts.length.should.eql non-repeat-contacts-amount


  # TODO: 检查merge细节正确
  # result-contact = merged-result-contacts[0]
  # result-contact.merged-from.length.should.eql 1

  callback!

is-merged-result-contact = (contact) ->
  return !contact.merged-to

create-and-check-user-with-mulitple-repeat-contacts = (json-file-name, user-name, callback)->
  user-data = util.load-json __dirname + "/../test-data/#{json-file-name}"
  non-repeat-contacts-amount = add-multiple-repeat-contacts user-data, multiple-times, repeat-rate
  # console.log "\\\\\\\\\\\\\\\\\\\\\\\ user-data.contacts \\\\\\\\\\\\\\\\\\\\\\\\\\n"
  # show-contacts user-data.contacts
  (user) <-! User.create-user-with-contacts db, user-data
  (err, found-users) <-! db.users.find({name: user-name}).to-array
  found-users.length.should.eql 1
  found-users[0].name.should.eql user-name
  console.log "\n\t成功创建了User：#{found-users[0].name}"
  callback non-repeat-contacts-amount 

add-multiple-repeat-contacts = (user-data, multiple-times, repeat-rate) ->
  seed-contacts = JSON.parse JSON.stringify user-data.contacts # Deep Clone
  non-repeat-contacts-amount = 0
  for i in [1 to multiple-times]
    if repeat-rate <= Math.random! then 
      new-contact =generate-random-contact! 
      non-repeat-contacts-amount++
    else 
      new-contact = generate-repeat-contact seed-contacts
    user-data.contacts.push new-contact
  # console.log "\n\n*************** #{non-repeat-contacts-amount} ***************\n\n"
  non-repeat-contacts-amount

generate-random-contact = -> 
  "names": [util.get-UUid!] 

generate-repeat-contact = (seed-contacts)->
  dif-keys = ['phones', 'emails']
  keys = ['ims', 'phones']
  contact = {}
  different-value-key = random-select dif-keys
  contact[different-value-key] = [Math.random! * 100000 + '']

  repeat-value-key = random-select keys
  seed = random-select filter is-defined(repeat-value-key), seed-contacts
  contact[repeat-value-key] = seed[repeat-value-key]
  contact.names ||= ["repeat-contact-on-#{repeat-value-key}"] 
  contact 

random-select = (elements)->
  throw new Error "Can't' random select form #{elements}" if !elements
  elements[Math.floor(Math.random! * elements.length)]

is-defined = (key, obj) -->
  _.is-array obj[key] and obj[key].length > 0

show-contacts = (contacts) ->
  return if !contacts
  extening-string!
  console.log "\n\nid \t name \t\t phone \t\t im \t\t m-to \t\t m-from\n"
  for contact in contacts
    phone = if contact?.phones?.length and contact.phones[0] then contact.phones[0].last-substring(6) else ' '  * 6
    im = if contact?.ims?.length then contact.ims[0]?.account?.last-substring(6) else ' '  * 6
    m-to = if contact?.merged-to then contact.merged-to.last-substring(6) else ' '  * 6
    m-from = if contact?.merged-from?.length then [f.last-substring(6) for f in contact.merged-from] else ' '  * 6
    console.log "#{contact?.cid?.last-substring(6)} \t #{contact.names[0].last-substring(6)} \t #{phone} \t #{im} \t\t #{m-to} \t#{m-from}" 

extening-string = !->
  String.prototype.last-substring = (position)->
    @substring(@length - position, @length)