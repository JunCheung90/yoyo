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
    check-and-merge-contacts contact, checked-contacts 
    checked-contacts.push contact 

check-and-merge-contacts = !(checking-contact, checked-contacts) ->
  for contact in checked-contacts
    continue if contact.merged-to # 不合并到已经被合并的用户
    continue if contact.cid in (checking-contact?.not-merge-with || []) # 不合并用户之前已经拒绝的合并
    is-merging = should-contacts-be-merged contact, checking-contact
    continue if is-merging is "NONE"

    distination = select-distination contact, checking-contact
    source = if distination.cid is contact.cid then checking-contact else contact
    direct-merge-contacts source, distination if is-merging is "DIRECT"
    pending-merge-contacts source, distination if is-merging is "PENDING" 

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


direct-merge-contacts = (source, distination) ->
  distination.merged-from ||= []
  distination.merged-from.push source.cid
  source.merged-to = distination.cid
  distination.act-by-user ||= source.act-by-user 
  merge-contacts-info source, distination
  update-pendings source, distination

pending-merge-contacts = (source, distination) ->
  source.pending-mergences ||= []
  source.pending-mergences.push = {'pending-merge-to': distination.cid}
  distination.pending-mergences ||= []
  distination.pending-mergences.push = {'pending-merge-from': source.cid}
  distination
  
update-pendings = !(source, distination) ->
  if !source.pending-mergences then return
  distination.pending-mergences ||= []
  distination.pending-mergences ++ source.pending-mergences 
  # TODO: source和distination合并之后，每个pending的mergence，其merge-to和对应的merge-from可能会变化。
  # 因为合并前可能是merged-to，合并到另外的联系人；但是merge后，信息丰富了，可能应该变成merged-from，将其他联系人合并过来。

merge-contacts-info = (source, distination) -> # 合并除了merge状态的属性之外的所有属性，合并时做并集操作。
  for key in _.keys source
    continue if key in ['cid', 'mergedTo', 'mergedFrom', 'pendingMergences']
    if _.is-array source[key] then
      distination[key] = combine source[key], distination[key]
    else
      throw new Error "#{distination.names} and #{source.names} contact merging CONFLICT for key: #{key}, with different value: #{distination[key]}, #{source[key]}" if distination[key] != source[key]

  distination

select-distination = (c1, c2) ->
  c1 # TODO: 这里需要比较两个联系人的最后更新时间、最后联系时间、联系次数、等等进行确定。又或者和合并一样，需要外置规则。

combine = (source, distination) ->
  return if source.length is 0 and distination.length is 0
  if source[0]?.type # ims, sns
    for s in source
      for d in distination
        if _.is-equal s, d and s 
          exist = true 
          break
      distination.push s if !exist 
      exist = false
  else
    debugger
    distination = _.union distination, source
  distination 

(exports ? this) <<< {merge-contacts}   