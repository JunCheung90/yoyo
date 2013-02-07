require! ['../src/util', '../src/models/User']
_ = require 'underscore'

helper =
  create-and-check-user-with-mulitple-repeat-contacts: (db, json-file-name, user-name, multiple-times, repeat-rate, callback)->
    user-data = util.load-json __dirname + "/test-data/#{json-file-name}"
    non-repeat-contacts-amount = add-multiple-repeat-contacts user-data, multiple-times, repeat-rate
    # console.log "\\\\\\\\\\\\\\\\\\\\\\\ user-data.contacts \\\\\\\\\\\\\\\\\\\\\\\\\\n"
    # show-contacts user-data.contacts
    (user) <-! User.create-user-with-contacts db, user-data
    (err, found-users) <-! db.users.find({name: user-name}).to-array
    found-users.length.should.eql 1
    found-users[0].name.should.eql user-name
    console.log "\n\t成功创建了User：#{found-users[0].name}"
    callback non-repeat-contacts-amount 

  show-contacts: (contacts) ->
    return if !contacts
    extening-string!
    console.log "\n\nid \t name \t\t phone \t\t im \t\t m-to \t\t m-from\n"
    for contact in contacts
      phone = if contact?.phones?.length and contact.phones[0] then contact.phones[0].last-substring(6) else ' '  * 6
      im = if contact?.ims?.length then contact.ims[0]?.account?.last-substring(6) else ' '  * 6
      m-to = if contact?.merged-to then contact.merged-to.last-substring(6) else ' '  * 6
      m-from = if contact?.merged-from?.length then [f.last-substring(6) for f in contact.merged-from] else ' '  * 6
      console.log "#{contact?.cid?.last-substring(6)} \t #{contact.names[0].last-substring(6)} \t #{phone} \t #{im} \t #{m-to} \t#{m-from}" 


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
  keys = ['ims'] # 这里如果用多个key的话，会出现搭桥的现象，导致原本不重复的contact变成重复的。
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

extening-string = !->
  String.prototype.last-substring = (position)->
    @substring(@length - position, @length)

module.exports = helper