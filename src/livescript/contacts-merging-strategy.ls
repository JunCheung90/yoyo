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

  double-check: # 1st和2nd check都为真，direct merge；first为假，none merge；fist真，second假，按照false-result取值返回
    * first-check:
        checker: 'is-one-same'
        fields: ['phones', 'ims']
      second-check:
        checker: 'is-communication-log-unoverlapped' # emails相同时，如果两个联系人有交叠的通讯历史，应该是不同联系人。
        false-result: 'NONE' # NONE | PENDING | NOT_DECIDED   不合并 | 推荐合并 | 不确定（看下一个）
    ...

  recommand-merging: # 这些字段的内容如果相似，则推荐合并
    # 每个key定义了需要进行的检查，只要有一个检查为true，则推荐合并。
    'is-similar-name': ['name']
    'is-same-owner-dif-provider' : ['emails'] # 这项可能太强了，需要进一步考虑。

convert-checkers-to-camel-case = ->
  real-strategy = {direct-merging:{}, double-check:[], pending-merging:{}}
  for key in _.keys contacts-merging-strategy.direct-merging
    real-strategy.direct-merging[util.to-camel-case key] = contacts-merging-strategy.direct-merging[key]
  
  for key in _.keys contacts-merging-strategy.recommand-merging
    real-strategy.pending-merging[util.to-camel-case key] = contacts-merging-strategy.recommand-merging[key]

  for check in contacts-merging-strategy.double-check
    check.first-check.checker = util.to-camel-case check.first-check.checker
    check.second-check.checker = util.to-camel-case check.second-check.checker
    real-strategy.double-check.push check
  
  real-strategy

module.exports = convert-checkers-to-camel-case contacts-merging-strategy 