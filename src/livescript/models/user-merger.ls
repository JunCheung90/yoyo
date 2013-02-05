require! fqh: '../fast-query-helper'
require! ['./Info-Combiner', '../util']
_ = require 'underscore'

user-merger =
  merge-same-users: !(db, user, callback) -> 
    # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
    (existed-user, is-direct-merge) <-! fqh.get-existed-repeat-users db, user 
    if existed-user
      throw new Error "Can't merge a user: #{user.name} to an existed-user: #{existed-user.name} already being merged to others #{existed-user.merged-to}" if existed-user.merged-to
      throw new Error "Can't merge a already mereged user: #{user.name}, merged-to: #{user.merged-to} to an existed-user: #{existed-user.name}" if user.merged-to
      if is-direct-merge
        Info-Combiner.combine-users-info existed-user, user
        Info-Combiner.combine-users-mergences  existed-user, user if user.uid # user为已有用户，否则是希望新建的用户。对于希望新建的用户如果要merge到其它用户，不用新建，直接copy信息就好了。
        re-evaluate-user-pending-mergences db, existed-user if existed-user?.pending-merges?.length # 是否应该回调？
        callback existed-user, null # 彻底合并了，只需要更新一个user了。
      else
        Info-Combiner.add-users-pending-merges existed-user, user
        callback existed-user, user
    else
      callback null, user

   # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
  merge-contacts: !(db, contact, owner, callback) ->
    contact-user = create-contact-user contact
    (old-user, new-user) <-! merge-same-users db, contact-user
    contact-act-by-user = new-user or old-user
    bind-contact-with-user contact, contact-act-by-user, owner
    if old-user # existing old user for the contact, hence perhaps being repeat contacts 
      is-direct-merge = !new-user
      merge-contacts-within-same-contacts-book old-user, new-user, contact, is-direct-merge
    callback old-user, new-user

create-contact-user = (contact) ->
  user = {} <<< contact{emails, ims, sns}
  user.nicknames = contact.names
  if contact?.phones?.length
    user.phones = []
    for phone in contact.phones
      user.phones.push {phone-number: phone}
  user

binb-contact-with-user = !(contact, user, owner) ->
  contact.act-by-user = user.uid
  user.as-contact-of ||= []
  _.union user.as-contact-of owner.uid

merge-contacts-within-same-contacts-book = !(old-user, new-user, contact, is-direct-merge) ->
  if old-contact = get-contact-act-by-user old-user.contacts, contact.act-by-user
    if is-direct-merge
      Info-Combiner.combine-contacts-info old-contact, contact
      Info-Combiner.combine-contacts-mergences old-contact, contact
      # 所有的merge本质上都是user的merge，users merge之后，传递到了他们act的contact，因此这里不需要re-evaluate pendings.
    else
      Info-Combiner.add-contacts-pending-merges old-contact, contact

get-contact-act-by-user = (contacts, act-by-user) ->
  return null if contacts?.length
  for contact in contacts
    return contact if contact.act-by-user is act-by-user

re-evaluate-user-pending-mergences = !(db, existed-user) ->
  #TODO:
  console.log 'NOT IMPLEMENTED YET'

module.exports = user-merger  