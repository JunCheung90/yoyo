require! ['../bin/util', '../bin/db/database', '../bin/models/Users']
_ = require 'underscore'

helper =
  create-and-check-user: !(json-file-name, user-name, callback) ->
    helper.create-and-check-user-with-mulitple-repeat-contacts json-file-name, user-name, 0, 0, callback

  create-and-check-user-with-mulitple-repeat-contacts: !(json-file-name, user-name, multiple-times, repeat-rate, callback)->
    # 这里用require，会导致第二次load json时，直接用的是缓存，而不是重新load！！
    user-data = helper.load-user-data json-file-name
    non-repeat-contacts-amount = add-multiple-repeat-contacts user-data, multiple-times, repeat-rate
    # console.log "\\\\\\\\\\\\\\\\\\\\\\\ user-data.contacts \\\\\\\\\\\\\\\\\\\\\\\\\\n"
    # @show-contacts user-data.contacts

    (db) <-! database.get-db
    (user) <-! Users.create-user-with-contacts user-data
    (err, found-users) <-! db.users.find({name: user-name}).to-array
    found-users.length.should.eql 1
    found-users[0].name.should.eql user-name
    console.log "\n\t成功创建了User：#{found-users[0].name}"
    callback non-repeat-contacts-amount 

  load-user-data: (json-file-name) ->
    util.load-json __dirname + "/test-data/#{json-file-name}"

  show-contacts: (contacts) ->
    return if !contacts
    extending-string!
    console.log "\n\nid \t name \t\t phone \t\t im \t\t m-to \t\t m-from\n"
    for contact in contacts
      phone = if contact?.phones?.length and contact.phones[0] then contact.phones[0].last-substring(6) else ' '  * 6
      im = if contact?.ims?.length then contact.ims[0]?.account?.last-substring(6) else ' '  * 6
      m-to = if contact?.merged-to then contact.merged-to.last-substring(6) else ' '  * 6
      m-from = if contact?.merged-from?.length then [f.last-substring(6) for f in contact.merged-from] else ' '  * 6
      console.log "#{contact?.cid?.last-substring(6)} \t #{contact.names[0].last-substring(6)} \t #{phone} \t #{im} \t #{m-to} \t#{m-from}" 


  are-contacts-merged-correct: !(contacts, non-repeat-contacts-amount, callback) ->
    # test-helper.show-contacts contacts
    merged-result-contacts = filter is-merged-result-contact, contacts
    # test-helper.show-contacts merged-result-contacts
    merged-result-contacts.length.should.eql non-repeat-contacts-amount
    # TODO: 检查merge细节正确
    # result-contact = merged-result-contacts[0]
    # result-contact.merged-from.length.should.eql 1

    callback!

  check-user-contacts: !(user-name, amount-of-has-contacts, amount-of-as-contacts, callback) ->
    (db) <-! database.get-db
    (err, found-users) <-! db.users.find({name: user-name}).to-array
    found-users.length.should.eql 1
    found-user = found-users[0]
    found-user.contacts.length.should.eql amount-of-has-contacts
    # console.log "\n\t找回的User：#{user-name}有#{found-user.contacts.length}个联系人：%j", [[name for name in contact.names] for  contact in found-user.contacts]
    found-user-amount-of-as-contacts = found-user?.as-contact-of?.length or 0
    found-user-amount-of-as-contacts.should.eql amount-of-as-contacts
    console.log "\n\t找回的User：#{user-name}作为#{found-user-amount-of-as-contacts}个联系人"

    console.log "\n\t找回的User：#{user-name}有#{found-user.sns.length}个SN：%j" [{sn.sn-name, sn.account-name} for sn in found-user.sns]

    callback!      

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
  "phones": [generate-random-phone-number!]

generate-repeat-contact = (seed-contacts)->
  dif-keys = ['phones']
  keys = ['ims'] # 这里如果用多个key的话，会出现搭桥的现象，导致原本不重复的contact变成重复的。
  contact = {}
  different-value-key = random-select dif-keys
  contact[different-value-key] = [generate-random-phone-number!]

  repeat-value-key = random-select keys
  seed = random-select filter is-defined(repeat-value-key), seed-contacts
  contact[repeat-value-key] = seed[repeat-value-key]
  contact.names ||= ["repeat-contact-on-#{repeat-value-key}"] 
  contact

generate-random-phone-number = ->
  phone-number = (Math.floor (1 + Math.random!) * Math.pow 10, 10) + ''
  # console.log "Phone Number: %j", phone-number
  phone-number

random-select = (elements)->
  throw new Error "Can't' random select form #{elements}" if !elements
  elements[Math.floor(Math.random! * elements.length)]

is-defined = (key, obj) -->
  _.is-array obj[key] and obj[key].length > 0

extending-string = !->
  String.prototype.last-substring = (position)->
    @substring(@length - position, @length)

is-merged-result-contact = (contact) ->
  return !contact.merged-to


module.exports <<< helper