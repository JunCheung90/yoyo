_ = require 'underscore'

Checkers =
  same: (v1, v2) ->
    if _.is-array v1 then
      return true if !_.is-empty _.intersection v1, v2
    else
      return true if _.is-equal v1, v2
    false

  similar-name: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false

  same-owner-dif-provider: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false

module.exports = Checkers