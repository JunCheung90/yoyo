/**
 * Author: Zhang, JieJun. Email: JunCheung90@gmail.com
 * All rights reserved.
 */
require! Contacts: '../models/contacts', Users: '../models/users'
require! ['../util']
require! async

contact-manager = 
  synchronize-user-contacts: !(synchronize-data, callback) ->    
    (user) <-! Users.get-user-by-uid synchronize-data.uid    
    (err) <-! async.for-each synchronize-data.contacts, !(contact, next) ->
      if !contact.cid? || contact.cid == 0 || !contact.cid == ""
        user.contacts.push contact
        next!
      else
        modified-user-contact user, contact
        next!
    throw new Error err if err
    (user) <-! Users.update-user-contacts user
    # (err, result) <-! util.update-multiple-docs 'users', [user]
    # throw new Error err if err
    callback {result-code: 0, contacts:user.contacts}

modified-user-contact = !(user, contact) ->
  for i from 0 to user.contacts.length
    if contact.cid == user.contacts[i].cid
      if contact.cid-in-client == -1
        user.contacts.splice i, 1
      else
        for key, value of contact
          user.contacts[i][key] = value
      break

module.exports <<< contact-manager