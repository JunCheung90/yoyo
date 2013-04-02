/*
 * Created by Wang, Qing. All rights reserved.
 */

Merge-Strategy = require './strategy/contacts-merging-strategy'
_ = require 'underscore' 
require! ['../models/helpers/Info-Combiner', './User-Merger', '../models/Contacts']
require! common: './user-contact-common', Checkers: './checker/merge-checkers'

contact-merger =
 # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
  merge-contact-act-by-user-with-existed-users: !(contact, contact-user, owner, callback) ->
    (old-user, new-user) <-! User-Merger.create-user-then-merge-with-existed-user contact-user
    contact-act-by-user = new-user or old-user
    Contacts.bind-contact-with-user contact, contact-act-by-user, owner
    if old-user # existing old user act as the contact, hence perhaps being repeat contacts 
      is-direct-merge = !new-user
      # merge-contacts-act-by-same-saved-user-in-same-contacts-book owner, old-user, new-user, contact
      callback old-user, new-user
    else 
      callback null, new-user 

  merge-contacts: !(owner, contacts) ->
    if contacts
      owner.contacts-seq ||= 0
      checked-contacts = [] 
      for contact in contacts
        contact.cid ?= Contacts.create-cid owner.uid, ++owner.contacts-seq
        check-and-merge-contacts contact, checked-contacts, owner 
        checked-contacts.push contact 

  direct-merge-contacts: !(source, distination) ->
    Info-Combiner.combine-contacts-info distination, source
    Info-Combiner.combine-contacts-merge distination, source
    Contacts.add-contact-mergence-info distination, source
    common.update-pending-merges source, distination

  pending-merge-contacts: !(source, distination) ->
    Info-Combiner.add-contacts-pending-merges distination, source
    Contacts.add-volatile-pending-merge source, distination

select-distination = (c1, c2) ->
  c1 # TODO: 这里需要比较两个联系人的最后更新时间、最后联系时间、联系次数、等等进行确定。又或者和合并一样，需要外置规则。

check-and-merge-contacts = !(checking-contact, checked-contacts, owner) ->
  for contact in checked-contacts
    continue if contact.merged-to # 不合并到已经被合并的用户
    continue if contact.cid in (checking-contact?.not-merge-with || []) # 不合并用户之前已经拒绝的合并
    is-merging = should-contacts-be-merged contact, checking-contact, owner
    continue if is-merging is "NONE"

    distination = select-distination contact, checking-contact
    source = if distination.cid is contact.cid then checking-contact else contact
    contact-merger.direct-merge-contacts source, distination if is-merging is "DIRECT"
    contact-merger.pending-merge-contacts source, distination if is-merging is "PENDING" 

# ----------------------------------↓ 性能热点 ↓---------------------------------------------- #
# 占用了30% 左右的执行时间
should-contacts-be-merged = (-> # 使用闭包，避免重复计算direct-merge-checkers，改善了性能。
  # TODO：改用较为高效的数据结构（hash-table、B-tree等）存储所有的可能项（email、phone、im、sn），进行是否合并的查询。
    direct-merge-checkers =  _.keys Merge-Strategy.direct-merging
    (c1, c2, owner) ->
      return "NONE" if c1.merged-to or c2.merged-to # 不合并到已经合并的用户
      for checker in direct-merge-checkers
        for field in Merge-Strategy.direct-merging[checker]
          return "DIRECT" if Checkers[checker] c1[field], c2[field] 
          
      result = Checkers.double-check Merge-Strategy.double-check-direct-merging, c1, c2, owner, 'DIRECT'
      return result if result is not 'NOT_DECIDED'

      # PEDNDING merge check, all pending checkers are double-check checkers
      result = Checkers.double-check Merge-Strategy.recommand-merging, c1, c2, owner, 'PENDING'
      result = 'NONE' if result is 'NOT_DECIDED'
      result
    )() 
  
# ---------------------------------↑ 性能热点 ↑----------------------------------------------- #

module.exports <<< contact-merger