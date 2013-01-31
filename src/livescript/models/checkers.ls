_ = require 'underscore'

Checkers =
  same: (a, b) ->
    # console.log "\n\n*************** a: %j, b: %j, result %j ***************\n\n", a, b, _.is-equal(a, b) if _.is-array(a) and a.length is 0
    # console.log "\n\n*************** a: %j, b: %j, result %j ***************\n\n", a, b, _.is-equal(a, b) if a?.0?.account is 'zhangsan111'
    return false if !a or !b or (_.is-array(a) and a.length is 0 and _.is-array(b) and b.length is 0)
    _.is-equal a, b
    # if _.is-array a then
    #   return false if !a or !b
    #   for e1 in a
    #     for e2 in b
    #       return true if a and b and _.is-equal a, b
    # else
    #   return true if a and b and _.is-equal a, b
    # false

  one-same: (a, b) ->
    return false if !a or !b 
    # throw new Error "One of #{a} and #{b} is NOT an array!" if !_.is-array(a) or !_.is-array(b)
    for e-a in a
      for e-b in b
        return true if _.is-equal e-a, e-b
    false

  similar-name: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false 

  same-owner-dif-provider: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false

module.exports = Checkers 