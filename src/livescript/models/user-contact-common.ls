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
    # pending mergence不转移，用户确认时，再做相应调整。

module.exports = user-contact-common