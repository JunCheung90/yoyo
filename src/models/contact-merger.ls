/*
 * Created by Wang, Qing. All rights reserved.
 */

Merge-Strategy = require '../contacts-merging-strategy'
_ = require 'underscore' 
require! ['../util', './Checkers', './Info-Combiner', './User-Merger', './Contact']

contact-merger =
 # 算法参见 http://my.ss.sysu.edu.cn/wiki/pages/viewpage.action?pageId=113049608
 # 要先merge contact，然后再根据这个merge来新建user才对！
  merge-contact-act-by-user-with-users-AND-merge-itself-within-contacts-of-the-same-owner: !(contact, owner, callback) ->
    contact-user = Contact.create-contact-user contact
    (old-user, new-user) <-! User-Merger.create-user-then-merge-with-existed-user contact-user
    contact-act-by-user = new-user or old-user
    Contact.bind-contact-with-user contact, contact-act-by-user, owner
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
        contact.cid = Contact.create-cid owner.uid, ++owner.contacts-seq
        check-and-merge-contacts contact, checked-contacts, owner 
        checked-contacts.push contact 


# merge-contacts-act-by-same-saved-user-in-same-contacts-book = !(owner, old-user, new-user, contact) ->
#   is-direct-merge = !new-user
#   if merge-to-contact = Contact.get-merge-to-contact owner.contacts, contact, is-direct-merge
#     merge-contacts-within-same-contacts-book merge-to-contact, contact, is-direct-merge

merge-contacts-within-same-contacts-book = !(old-contact, new-contact, is-direct-merge) ->
  if is-direct-merge
    Info-Combiner.combine-contacts-info old-contact, new-contact
    Info-Combiner.combine-contacts-mergences old-contact, new-contact
    Contact.add-contact-mergence-info old-contact, new-contact
    # 所有的merge本质上都是user的merge，users merge之后，传递到了他们act的contact，因此这里不需要re-evaluate pendings.
  else
    Info-Combiner.add-contacts-pending-merges old-contact, new-contact

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
    direct-merge-contacts source, distination if is-merging is "DIRECT"
    pending-merge-contacts source, distination if is-merging is "PENDING" 

# ----------------------------------↓ 性能热点 ↓---------------------------------------------- #
# 占用了30% 左右的执行时间
should-contacts-be-merged = (-> # 使用闭包，避免重复计算direct-merge-checkers，改善了性能。
  # TODO：改用较为高效的数据结构（hash-table、B-tree等）存储所有的可能项（email、phone、im、sn），进行是否合并的查询。
    direct-merge-checkers =  _.keys Merge-Strategy.direct-merging
    # pending-merge-checkers = _.keys Merge-Strategy.pending-merging
    # [double-first-checkers, double-second-checkers] = get-double-checks!
    (c1, c2, owner) ->
      return "NONE" if c1.merged-to or c2.merged-to # 不合并到已经合并的用户
      for checker in direct-merge-checkers
        for field in Merge-Strategy.direct-merging[checker]
          return "DIRECT" if Checkers[checker] c1[field], c2[field] 
          
      result = double-check Merge-Strategy.double-check-direct-merging, c1, c2, owner, 'DIRECT'
      return result if result is not 'NOT_DECIDED'

      result = double-check Merge-Strategy.recommand-merging, c1, c2, owner, 'PENDING'
      result = 'NONE' if result is 'NOT_DECIDED'
      result

    )() 
  
# ---------------------------------↑ 性能热点 ↑----------------------------------------------- #

double-check = (checks, c1, c2, owner, result-of-pass-second-check)->
  # 返回 'DIRECT' | 'PENDING' | 'NONE' | 'NOT_DECIDED' 其中second-check.false-result 包括了除'DIRECT'之外的3种，@see contacts-merging-strategy
  for check in checks
    for field in check.first-check.fields
      if Checkers[check.first-check.checker] c1[field], c2[field]
        if Checkers[check.second-check.checker] c1, c2, field, owner
          return result-of-pass-second-check 
        else
          result = check.second-check.false-result
          continue if result is 'NOT_DECIDED'
          return result

  return 'NOT_DECIDED'


get-double-checks = ->
  for check in Merge-Strategy.double-check-direct-merging
    first-checkers = util.union first-checkers check.first-checker
    second-checkers = util.union second-checkers check.second-checker
  [first-checkers, second-checkers]

direct-merge-contacts = (source, distination) ->
  Info-Combiner.combine-contacts-info distination, source
  Info-Combiner.combine-contacts-mergences distination, source
  Contact.add-contact-mergence-info distination, source
  update-pending-mergences source, distination

pending-merge-contacts = (source, distination) ->
  Info-Combiner.add-contacts-pending-merges distination, source
  
update-pending-mergences = !(source, distination) ->
  # if !source.pending-mergences then return
  # distination.pending-mergences ||= []
  # distination.pending-mergences ++ source.pending-mergences 
  # TODO: source和distination合并之后，每个pending的mergence，其merge-to和对应的merge-from可能会变化。
  # 因为合并前可能是merged-to，合并到另外的联系人；但是merge后，信息丰富了，可能应该变成merged-from，将其他联系人合并过来。


module.exports = contact-merger