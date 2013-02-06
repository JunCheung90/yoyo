/*
 * Created by Wang, Qing. All rights reserved.
 */

Merge-Strategy = require '../contacts-merging-strategy'
_ = require 'underscore' 
require! ['../util', './Checkers', './Info-Combiner', './User-Merger', './Contact']

contact-merger =
 # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
 # 要先merge contact，然后再根据这个merge来新建user才对！
  merge-contact-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner: !(db, contact, owner, to-create-users, callback) ->
    contact-user = Contact.create-contact-user contact
    (old-user, new-user) <-! User-Merger.create-user-then-merge-with-existed-user db, contact-user
    contact-act-by-user = new-user or old-user
    Contact.bind-contact-with-user contact, contact-act-by-user, owner
    if old-user # existing old user act as the contact, hence perhaps being repeat contacts 
      is-direct-merge = !new-user
      merge-contacts-act-by-same-saved-user-in-same-contacts-book owner, old-user, new-user, contact
      Info-Combiner.combine-users-info to-create-users[contact.cid], new-user if is-direct-merge and to-create-users[contact.cid]
      callback old-user, new-user
    else 
      new-user = check-and-merge-with-unsaved-contact contact, new-user, owner
      callback null, new-user

merge-contacts-act-by-same-saved-user-in-same-contacts-book = !(owner, old-user, new-user, contact) ->
  is-direct-merge = !new-user
  if merge-to-contact = Contact.get-merge-to-contact owner.contacts, contact, is-direct-merge
    merge-contacts-within-same-contacts-book merge-to-contact, contact, is-direct-merge

merge-contacts-within-same-contacts-book = !(old-contact, new-contact, is-direct-merge) ->
  if is-direct-merge
    Info-Combiner.combine-contacts-info old-contact, new-contact
    Info-Combiner.combine-contacts-mergences old-contact, new-contact
    Contact.add-contact-mergence-info old-contact, new-contact
    # 所有的merge本质上都是user的merge，users merge之后，传递到了他们act的contact，因此这里不需要re-evaluate pendings.
  else
    Info-Combiner.add-contacts-pending-merges old-contact, new-contact

check-and-merge-with-unsaved-contact = (checking-contact, new-user, owner) ->
  for contact in owner.contacts
    continue if !contact.act-by-user # 不合并到尚未创建的联系人
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

module.exports = contact-merger