require! ['should', '../../bin/database'
          '../../bin/servers-init'.init-mongo-client, 
          '../../bin/servers-init'.shutdown-mongo-client, '../test-helper']

db = null

helper =
  initial-environment: (callback) ->
    <-! init-mongo-client
    db := database.db
    <-! db.drop-collection 'users'
    user-data = test-helper.load-user-data 'dump-user.json'
    callback user-data

  should-find-one-user-named: !(username, callback) ->
    (found-user) <-! should-find-one-user-with-cretiria {'name': username}
    found-user.name.should.eql username
    callback found-user

  should-find-one-user-with-cretiria: !(cretiria, callback) ->
    (found-users) <-! should-find-users cretiria, 1
    found-user = found-users[0]
    callback found-user

  should-find-users: !(cretiria, amount, callback) ->
    (err, found-users) <-! db.users.find(cretiria).to-array
    found-users.should.have.length amount
    callback found-users

  should-find-one-user-with-nickname: !(nickname, callback) ->
    (found-users) <-! should-find-users {'nicknames':nickname}, 1
    found-user = found-users[0]
    found-user.nicknames.should.include nickname
    callback found-user

  should-find-all-users-amount-be: !(amount, callback) ->
    (found-users) <-! should-find-users {}, amount
    callback found-users

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

  should-be-pending-merge-users-pair: (a, b) ->
    should-be-pending-merge-pair a, b, 'uid'

  should-be-pending-merge-pair: (a, b, attr) ->
    a.should.have.property('pendingMerges')
    a.pending-merges.length.should.be.greater-than 0

  get-pending-tos-and-froms: (pending-merges) ->
    pending-to = [p.pending-merge-to for p in pending-merges when p.pending-merge-to]
    pending-from = [p.pending-merge-from for p in pending-merges when p.pending-merge-from]
    [pending-to, pending-from]

module.exports = helper