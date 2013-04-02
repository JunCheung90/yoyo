/*
 * Created by Wang, Qing. All rights reserved.
 * This scipt holds common features of a user and a contact
 */
_ = require 'underscore'

user-contact-common = 
  add-mergence-info: (old, _new, linker) ->
    _new.merged-to = old[linker]
    old.merged-from ||= []
    old.merged-from.push _new[linker]

  update-pending-merges: !(source, distination) ->
    if source?.pending-merges?.length and distination?.pending-merges?.length
      remove-pending-merges-with source.pending-merges, distination.cid
      remove-pending-merges-with distination.pending-merges, source.cid

remove-pending-merges-with = !(pending-merges, related-cid) ->
  index = -1
  for p, i in pending-merges
    index = i if p.pending-merge-to is related-cid or p.pending-merge-from is related-cid
  pending-merges.splice index, 1 if index is not -1



module.exports <<< user-contact-common