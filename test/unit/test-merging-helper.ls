require! ['should', 'async', 
          '../../bin/models/User',
          '../../bin/servers-init'.init-mongo-client, 
          '../../bin/servers-init'.shutdown-mongo-client,
          '../../bin/util', '../test-helper']
require! fqh: '../../bin/fast-query-helper', helper: './test-merging-helper'

helper =
  initial-test-environment: (callback) ->
    (mongo-client, mongo-db) <-! init-mongo-client
    <-! mongo-db.drop-collection 'users'
    user-data = test-helper.load-user-data 'dump-user.json'
    callback mongo-db, mongo-client, user-data

  should-found-one-user-named: !(db, username, callback) ->
    (err, found-users) <-! db.users.find({name: username}).to-array
    found-users.length.should.eql 1
    found-user = found-users[0]
    found-user.name.should.eql username
    callback found-user

  should-one-contact-is-to: (contacts) ->
    helper.should-amount-of-to-eql contacts, 1
    
  should-one-contact-is-from: (contacts) ->
    helper.should-amount-of-from-eql contacts, 1

  should-amount-of-to-eql: (contacts, amount-of-to) ->
    tos = filter (.merged-to), contacts 
    tos.length.should.eql amount-of-to

  should-amount-of-from-eql: (contacts, amount-of-from) ->
    froms = filter (.merged-from), contacts 
    froms.length.should.eql amount-of-from

  get-the-merged-contact: (contacts) ->
    merged-contacts = filter (.merged-from), contacts 
    merged-contacts[0]

  should-amount-of-contacts-has-pending-mergences-eql: (contacts, amount) ->
    pending-merge-contacts = filter (.pending-merges.length), contacts
    pending-merge-contacts.length.should.eql amount

  get-pending-merging-contacts: (contacts) ->
    for contact in contacts
      source = contact if contact?.pending-merges[0].pending-merge-to
      distination = contact if contact?.pending-merges[0].pending-merge-from
    [source, distination]

module.exports = helper