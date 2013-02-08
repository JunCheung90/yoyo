_ = require 'underscore'

Checkers =
  is-same: (a, b) ->
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

  is-one-same: (a, b) ->
    return false if !a or !b 
    # throw new Error "One of #{a} and #{b} is NOT an array!" if !_.is-array(a) or !_.is-array(b)
    for e-a in a
      for e-b in b
        return true if _.is-equal e-a, e-b
    false

  is-similar-name: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false 

  is-same-owner-dif-provider: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false

  is-communication-log-unoverlapped: (c1, c2, same-field, contacts-owner)->
    # TODO: 检查这里两个联系人c1, c2，看看其与contacts-owner的通讯记录有无交叠
    true

module.exports = Checkers 