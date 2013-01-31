_ = require 'underscore'

Checkers =
  same: (v1, v2) ->
    # console.log "\n\n*************** v1: %j, v2: %j, result %j ***************\n\n", v1, v2, _.is-equal(v1, v2) if _.is-array(v1) and v1.length is 0
    console.log "\n\n*************** v1: %j, v2: %j, result %j ***************\n\n", v1, v2, _.is-equal(v1, v2) if v1?.0?.account is 'zhangsan111'
    return false if !v1 or !v2 or (_.is-array(v1) and v1.length is 0 and _.is-array(v2) and v2.length is 0)
    _.is-equal v1, v2
    # if _.is-array v1 then
    #   return false if !v1 or !v2
    #   for e1 in v1
    #     for e2 in v2
    #       return true if v1 and v2 and _.is-equal v1, v2
    # else
    #   return true if v1 and v2 and _.is-equal v1, v2
    # false

  similar-name: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false 

  same-owner-dif-provider: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false

module.exports = Checkers 