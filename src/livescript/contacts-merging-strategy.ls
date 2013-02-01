/*
 * Created by Wang, Qing. All rights reserved.
 */

require! ['./util']
_ = require 'underscore'

# 注意：这里还没有考虑用户输入误差的问题，例如电话输错了一位，或者少输入一位的情况。
contacts-merging-strategy =
  direct-merging: # 这些字段的内容如果相同，则可以直接合并
    'actByUser': ['same']
    'emails': ['one-same']
    # ！！！ 这里不同于用户合并，一个用户的联系人中，不同联系人使用相同的phone、im、sns的概率几乎为零！！！
    'phones': ['one-same'] 
    'ims': ['one-same']
    'sns': ['one-same']
  recommand-merging: # 这些字段的内容如果相似，则推荐合并
    # 每个key对应的数组，定义了需要进行的检查，只要有一个检查为true，则推荐合并。
    # 这里数组元素的名字，就是检查时函数的名称（变化为camelCase）相似示例
    'names': ['similar-name']
    # same-owner-dif-provider：张老三、张大三；zhangsan@fake.com zansan
    'emails' : ['same-owner-dif-provider'] # 这项可能太强了，需要进一步考虑。

camel-case-checkers = ->
    for key in _.keys contacts-merging-strategy.direct-merging
        for value, i in contacts-merging-strategy.direct-merging[key]
            contacts-merging-strategy.direct-merging[key][i] = util.to-camel-case value

    for key in _.keys contacts-merging-strategy.recommand-merging
        for value, i in contacts-merging-strategy.recommand-merging[key]
            contacts-merging-strategy.recommand-merging[key][i] = util.to-camel-case value

    contacts-merging-strategy

module.exports = camel-case-checkers contacts-merging-strategy