/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['./util']
_ = require 'underscore'

# 注意：这里还没有考虑用户输入误差的问题，例如电话输错了一位，或者少输入一位的情况。
contacts-merging-strategy =
  direct-merging: # 这些字段的内容如果相同，则可以直接合并
    'is-same': ['actByUser']
    'is-one-same': ['emails', 'sns'] # 顺序对性能有较大影响。将最有可能重复的排在最前面。

  double-check-direct-merging: # 1st和2nd check都为真，direct merge；first为假，none merge；fist真，second假，按照false-result取值返回
    * first-check:
        checker: 'is-one-same'
        fields: ['phones', 'ims']
      second-check:
        checker: 'is-communication-log-unoverlapped' # emails相同时，如果两个联系人有交叠的通讯历史，应该是不同联系人。
        false-result: 'NONE' # NONE | PENDING | NOT_DECIDED   不合并 | 推荐合并 | 不确定（看下一个）
    ...

  recommand-merging: 
    * first-check:
        checker: 'is-one-similar'
        fields: ['names']
      second-check:
        checker: 'is-communication-log-unoverlapped' # name相似，通讯历史互不重叠，应该推荐合并。
        false-result: 'NONE' # NONE | PENDING | NOT_DECIDED   不合并 | 推荐合并 | 不确定（看下一个）
    ...

convert-checkers-to-camel-case = ->
  real-strategy = {direct-merging:{}, double-check-direct-merging:[], recommand-merging:[]}
  for key in _.keys contacts-merging-strategy.direct-merging
    real-strategy.direct-merging[util.to-camel-case key] = contacts-merging-strategy.direct-merging[key]

  conver-double-checkers real-strategy, util.to-camel-case 'double-check-direct-merging'
  conver-double-checkers real-strategy, util.to-camel-case 'recommand-merging'
  
  real-strategy

conver-double-checkers = (real-strategy, key) ->
  for check in contacts-merging-strategy[key]
    check.first-check.checker = util.to-camel-case check.first-check.checker
    check.second-check.checker = util.to-camel-case check.second-check.checker
    real-strategy[key].push check

module.exports <<< convert-checkers-to-camel-case contacts-merging-strategy 