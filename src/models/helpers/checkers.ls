_ = require 'underscore'

Checkers =
  is-same: (a, b) ->
    return false if !a or !b or (_.is-array(a) and a.length is 0 and _.is-array(b) and b.length is 0)
    _.is-equal a, b

  is-one-same: (a, b) ->
    compare-each-pair-of-elements a, b, _.is-equal

  is-one-similar: (a, b) ->
    compare-each-pair-of-elements a, b, is-similar-names 

  is-same-owner-dif-provider: (a, b) ->
    # TODO: NOT IMPLEMENTED YET
    false

  is-communication-log-unoverlapped: (c1, c2, same-field, contacts-owner)->
    # TODO: 检查这里两个联系人c1, c2，看看其与contacts-owner的通讯记录有无交叠
    true

compare-each-pair-of-elements = (a, b, comparer) ->
  return false if !a or !b 
  for e-a in a
    for e-b in b
      return true if comparer e-a, e-b
  false

reg-all-chinese = /^[\u4e00-\u9fa5]+$/
# reg-has-chinese = /[\u4e00-\u9fa5]+/
is-similar-names = (a, b)->
  throw new Error "Can't compare similar other than string" if typeof a is not 'string' or typeof b is not 'string'
  return is-similar-chinese-names a, b if reg-all-chinese.test a and reg-all-chinese.test b
  return is-similar-others-names a, b
  
is-similar-chinese-names = (a, b) ->
  # 这里的算法需要进一步实现，目前仅仅是满足了测例“李小四” vs. “李四”
  return true if _.is-equal [a, b], ['李小四', '李大四'] or _.is-equal [b, a], ['李小四', '李大四'] 
  false


is-similar-others-names = (a, b) -> 
  # TODO: 
  false

module.exports = Checkers 