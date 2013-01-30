/*
 * Created by Wang, Qing. All rights reserved.
 */

# TODO：这里复杂的合并逻辑还没有完成：1）
Merge-Strategy = require '../contacts-merging-strategy'
_ = require 'underscore' 
require! ['../util', './Checkers']

merge-contacts = !(contacts) ->
  checked-contacts = []
  for contact in contacts
    uid = util.get-UUid!
    contact.act-by-user = util.get-UUid!
    check-and-merge-contacts contact, checked-contacts 
    checked-contacts.push contact 

check-and-merge-contacts = !(checking-contact, checked-contacts) ->
  # TODO：多次合并的逻辑还没有厘清。
  for contact in checked-contacts
    continue if contact.merged-to # 不合并到已经被合并的用户
    continue if contact.cid in (checking-contact?.not-merge-with || [])
    is-merging = should-contacts-be-merged contact, checking-contact
    continue if is-merging is "NONE"

    console.log "\ncontact: #{contact.names[0]} and #{checking-contact} should be #{is-merging} merging.\n"

    distination = select-distination contact, checking-contact
    source = if distination is contact.cid then checking-contact else contact
    direct-merge-contacts source, distination if is-merging is "DIRECT"
    pending-merge-contacts source, distination if is-merging is "PENDING"

that = this 
should-contacts-be-merged = (c1, c2) ->
  return "NONE" if c1.merged-to or c1.merged-to # 不合并到已经合并的用户

  direct-merge-checking-fields = _.keys Merge-Strategy.direct-merging
  pending-merge-checking-fields = _.keys Merge-Strategy.recommand-merging

  for key in direct-merge-checking-fields 
    for checker in Merge-Strategy.direct-merging[key]
      checker = util.to-camel-case checker
      return "DIRECT" if Checkers[checker] c1[key], c2[key]

  for key in pending-merge-checking-fields
    for checker in Merge-Strategy.recommand-merging[key]
      checker = util.to-camel-case checker
      return "PENDING" if Checkers[checker] c1[key], c2[key]

  "NONE"


direct-merge-contacts = (source, distination) ->
  distination.merged-from ||= []
  distination.merged-from.push source.cid
  source.merged-to = distination.cid
  distination.act-by-user ||= soucre.act-by-user 

  update-source-pendings source, distionation if source.pending-mergences?.length
  update-distioncation-pendings distination, source if distination.pending-mergences?.length

  merge-contacts-info source, distination

pending-merge-contacts = (source, distination) ->
  source.pending-mergences ||= []
  source.pending-mergences.push = {'pending-merge-to': distination.cid}
  distination.pending-mergences ||= []
  distination.pending-mergences.push = {'pending-merge-from': source.cid}
  distination
  
# update-source-pendings = (source, distination) ->
#   source


merge-contacts-info = (source, distination) -> # 合并除了merge状态的属性之外的所有属性，合并时做并集操作。
  for key in _.keys source
    continue if key in ['cid', 'mergedTo', 'mergedFrom', 'pendingMergences']
    if _.is-array source[key] then
      distination[key] = _.union distination[key], source[key]
    else
      throw new Error "#{distination.names} and #{source.names} contact merging CONFLICT for key: #{key}, with different value: #{distination[key]}, #{source[key]}" if distination[key] != source[key]

  distination

select-distination = (c1, c2) ->
  c1 # TODO: 这里需要比较两个联系人的最后更新时间、最后联系时间、联系次数、等等进行确定。又或者和合并一样，需要外置规则。

(exports ? this) <<< {merge-contacts}  