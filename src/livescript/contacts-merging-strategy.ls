# 注意：这里还没有考虑用户输入误差的问题，例如电话输错了一位，或者少输入一位的情况。
contacts-merging-strategy =
  direct-merging: # 这些字段的内容如果相同，则可以直接合并
    'actByUser'
    'emails'
  recommand-merging: # 这些字段的内容如果相同，则推荐合并
    'phones'
    'ims'
    'sns'

module.exports = contacts-merging-strategy