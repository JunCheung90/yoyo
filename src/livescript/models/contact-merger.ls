/*
 * Created by Wang, Qing. All rights reserved.
 */

# TODO：这里复杂的合并逻辑还没有完成：1）
Merge-Strategy = require '../contacts-merging-strategy'
_ = require 'underscore' 
require! '../util'

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
    continue if contact.merged-to # 不会合并到已经被合并的用户
    switch should-contacts-be-merged contact, checking-contact
    case "NONE" then continue
    case "PENDING" then checking-contact.is-merge-pending = contact.is-merge-pending = true
    case "MERGED" then checking-contact.is-merge-pending = contact.is-merge-pending = false
    merge-two-contacts contact, checking-contact

should-contacts-be-merged = (c1, c2) ->
  # TODO：加载contacts-merging-strategy
  for key in Merge-Strategy.direct-merging
    if _.is-array c1[key] then
      return "MERGED" if !_.is-empty _.intersection c1[key], c2[key]
    else
      return "MERGED" if _.is-equal c1[key], c2[key]

  for key in Merge-Strategy.recommand-merging
    if _.is-array c1[key] then
      return "PENDING" if !_.is-empty _.intersection c1[key], c2[key]
    else
      return "PENDING" if _.is-equal c1[key], c2[key]

  "NONE"

merge-two-contacts = (c1, c2) -> # 返回null表示PENDING合并，没有真正合并内容；否则返回合并之后的Contact，整合所有信息到这个Contact。
  m-to = select-merge-to c1, c2 # 注意发现了与"PENDING"联系人相同的Cotact时，这里的m-to需要通盘考虑。
  m-from = if m-to.cid is c1.cid then c2 else c1
  m-to.merged-from ||= []
  m-to.merged-from.push m-from.cid
  m-from.merged-to = m-to.cid
  m-from.act-by-user = m-to.act-by-user

  if m-to.is-merge-pending then return null # "PENDING" 时，并不直接合并内容，而是等待用户处理后完成。
  for key in _.keys c1
    continue if key in ['cid', 'isMergePending', 'mergedTo', 'mergedFrom']
    if _.is-array c1[key] then
      m-to[key] = _.union m-to[key], m-from[key]
    else
      throw new Error "#{m-to.names} and #{m-from.names} contact merging CONFLICT for key: #{key}, with different value: #{m-to[key]}, #{m-from[key]}" if m-to[key] != m-from[key]

  m-to

select-merge-to = (c1, c2) ->
  c1 # TODO: 这里需要比较两个联系人的最后更新时间、最后联系时间、联系次数、等等进行确定。又或者和合并一样，需要外置规则。

(exports ? this) <<< {merge-contacts}  