Merge-Strategy = require '../contacts-merging-strategy'
require! fqh: '../fast-query-helper'
require! ['./Info-Combiner', './Checkers', '../util']
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
        add-user-mergence-info existed-user, user
        re-evaluate-user-pending-mergences db, existed-user if existed-user?.pending-merges?.length # 是否应该回调？
        callback existed-user, null # 彻底合并了，只需要更新一个user了。
      else
        Info-Combiner.add-users-pending-merges existed-user, user
        callback existed-user, user
    else
      callback null, user

   # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
  merge-contacts: !(db, contact, owner, to-create-users, callback) ->
    contact-user = create-contact-user contact
    (old-user, new-user) <-! user-merger.merge-same-users db, contact-user
    contact-act-by-user = new-user or old-user
    bind-contact-with-user contact, contact-act-by-user, owner
    if old-user # existing old user for the contact, hence perhaps being repeat contacts 
      is-direct-merge = !new-user
      merge-contacts-act-by-same-saved-user-in-same-contacts-book old-user, new-user, contact, is-direct-merge
      Info-Combiner.combine-users-info to-create-users[contact.cid], new-user if is-direct-merge and to-create-users[contact.cid]
      callback old-user, new-user
    else 
      new-user = check-and-merge-with-unsaved-contact contact, new-user, owner
      callback null, new-user

add-mergence-info = (old, _new, linker) ->
  _new.merged-to = old[linker]
  old.merged-from ||= []
  old.merged-from.push _new[linker]

add-user-mergence-info = (old-user, new-user) ->
  add-mergence-info old-user, new-user, 'uid'

add-contact-mergence-info = (old-contact, new-contact) ->
  add-mergence-info old-contact, new-contact, 'cid'



create-contact-user = (contact) ->
  user = {} <<< contact{emails, ims, sns}
  user.uid = util.get-UUid! 
  user.is-registered = false
  user.nicknames = contact.names
  if contact?.phones?.length
    user.phones = []
    for phone in contact.phones
      user.phones.push {phone-number: phone}
  user

bind-contact-with-user = !(contact, user, owner) ->
  contact.act-by-user = user.uid
  user.as-contact-of ||= [] 
  user.as-contact-of = _.union user.as-contact-of, owner.uid

merge-contacts-act-by-same-saved-user-in-same-contacts-book = !(old-user, new-user, contact, is-direct-merge) ->
  if old-contact = get-contact-act-by-user old-user.contacts, contact.act-by-user
    merge-contacts-within-same-contacts-book old-contact, contact, is-direct-merge

merge-contacts-within-same-contacts-book = !(old-contact, new-contact, is-direct-merge) ->
  if is-direct-merge
    Info-Combiner.combine-contacts-info old-contact, new-contact
    Info-Combiner.combine-contacts-mergences old-contact, new-contact
    add-contact-mergence-info old-contact, new-contact
    # 所有的merge本质上都是user的merge，users merge之后，传递到了他们act的contact，因此这里不需要re-evaluate pendings.
  else
    Info-Combiner.add-contacts-pending-merges old-contact, new-contact


get-contact-act-by-user = (contacts, act-by-user) ->
  if contacts?.length
    for contact in contacts
      return contact if contact.act-by-user is act-by-user
  else
    null

check-and-merge-with-unsaved-contact = (checking-contact, new-user, owner) ->
  for contact in owner.contacts
    continue if contact.merged-to # 不合并到已经被合并的用户
    continue if contact.cid is checking-contact.cid # 不合并到已经被合并的用户
    continue if contact.cid in (checking-contact?.not-merge-with || []) # 不合并用户之前已经拒绝的合并
    is-merging = should-contacts-be-merged contact, checking-contact
    continue if is-merging is "NONE"

    distination = select-distination contact, checking-contact
    source = if distination.cid is contact.cid then checking-contact else contact
    merge-contacts-within-same-contacts-book contact, checking-contact, is-merging is "DIRECT" 
    new-user = null if is-merging is "DIRECT" # 此时无需新建user了
  new-user

should-contacts-be-merged = (c1, c2) ->
  # TODO：改用较为高效的数据结构（hash-table、B-tree等）存储所有的可能项（email、phone、im、sn），进行是否合并的查询。
  return "NONE" if c1.merged-to or c2.merged-to # 不合并到已经合并的用户

  direct-merge-checking-fields = _.keys Merge-Strategy.direct-merging
  pending-merge-checking-fields = _.keys Merge-Strategy.recommand-merging

  for key in direct-merge-checking-fields 
    for checker in Merge-Strategy.direct-merging[key]
      return "DIRECT" if Checkers[checker] c1[key], c2[key]

  for key in pending-merge-checking-fields
    for checker in Merge-Strategy.recommand-merging[key]
      return "PENDING" if Checkers[checker] c1[key], c2[key]

  "NONE"

select-distination = (c1, c2) ->
  c1 # TODO: 这里需要比较两个联系人的最后更新时间、最后联系时间、联系次数、等等进行确定。又或者和合并一样，需要外置规则。


re-evaluate-user-pending-mergences = !(db, existed-user) ->
  #TODO:
  console.log 'NOT IMPLEMENTED YET'

module.exports = user-merger  