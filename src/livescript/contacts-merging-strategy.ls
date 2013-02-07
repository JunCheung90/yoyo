/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['./util']
_ = require 'underscore'

util.to-camel-case
# 注意：这里还没有考虑用户输入误差的问题，例如电话输错了一位，或者少输入一位的情况。
contacts-merging-strategy =
  direct-merging: # 这些字段的内容如果相同，则可以直接合并
    'is-same': ['actByUser']
    'is-one-same': ['phones', 'emails', 'ims', 'sns'] # 顺序对性能有较大影响。将最有可能重复的排在最前面。
    # 'actByUser': ['same']
    # 'emails': ['one-same']
    # # ！！！ 这里不同于用户合并，一个用户的联系人中，不同联系人使用相同的phone、im、sns的概率几乎为零！！！
    # 'phones': ['one-same'] 
    # 'ims': ['one-same']
    # 'sns': ['one-same']
  recommand-merging: # 这些字段的内容如果相似，则推荐合并
    # 每个key定义了需要进行的检查，只要有一个检查为true，则推荐合并。
    'is-similar-name': ['name']
    # same-owner-dif-provider：张老三、张大三；zhangsan@fake.com zansan
    'is-same-owner-dif-provider' : ['emails'] # 这项可能太强了，需要进一步考虑。

convert-checkers-to-camel-case = ->
  real-strategy = {direct-merging:{}, pending-merging:{}}
  for key in _.keys contacts-merging-strategy.direct-merging
    real-strategy.direct-merging[util.to-camel-case key] = contacts-merging-strategy.direct-merging[key]
  
  for key in _.keys contacts-merging-strategy.recommand-merging
    real-strategy.pending-merging[util.to-camel-case key] = contacts-merging-strategy.recommand-merging[key]
  
  real-strategy

module.exports = convert-checkers-to-camel-case contacts-merging-strategy