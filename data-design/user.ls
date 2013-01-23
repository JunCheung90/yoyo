user = # yoyo server端数据
  #----------- profile ----------#
  uid: 'xxxx' # 注册用户之后将存在, 对于尚未注册，而仅仅是通过他人通讯录识别的user，为null。
  is-person: true # true | false 对于单位用户（电话）来说为false
  name: '张三'
  nicknames: ['小张', '小三']
  avatars: ['s-aid-1', 's-aid-2', 'u-aid-1', 'u-aid-2'] # avatar的id全局唯一，有系统计算给出的（s）和用户上传的（u）
  current-avatar: 's-aid-2'
  phones: # 记录用户使用（过）的电话号码。
    * phone-number: '3456789'
      is-active: true
      start-using-time: '2012-11-05'
    * phone-number: '1'
      is-active: false
      start-using-time: '2010-01-01'
      end-using-time: '2012-11-01' # 
  ims: # 多个IM
    * type: 'QQ'
      account: '111111'
      is-active: true
      api-key: 'qq可能给出的api key' #所有api-key都不会给回手机端，仅仅是服务端用来获取用户update的信息，将来有可能会从user中移出去。
    * type: 'AOL'
      account: '222222'
      is-active: true
      api-key: 'AOL可能给出的api key'
  sn:
    * sn-name: '豆瓣'
      account-name: '张三豆'
      api-key: 'xxxx' # 服务端授权后得到的key，用以从SN获取信息。
    ...
  addresses:
    '广州 大学城 中山大学 至善园 307'
    ...
  tags: ['程序员']
  #----------- status ----------#
  is-registered: true
  last-modified-date: '2013-01-09'
  merge-status: 'NONE' # NONE | MERGED
  merged-to: null # 如果被合并了，这里是合并之后的uid。两个user合并时，新生成一个user。
  merged-from: [] # 如果是合并产生的user，这里记录合并前的uid
  #----------- relations ----------#
  contacts: # 当前用户的联系人
    * cid: 'uid-c-timestamp_of_add-seqno'
      names: ['李小四']
      phones: ['123456']
      emails: ['lisi@fake.com']
      ims: 
        * type: 'QQ'
          account: 'lisi111'
        ...
      sns: [] # 社交网络的列表
      tags: [] # 这些是当前用户给这个联系人定义的标签，说明了他们的关系
      #-------- merge --------#
      merge-status: 'NONE' # NONE | MERGED
      merged-to: null # 如果被合并了，这里是合并之后的cid。两个contact合并时，新生成一个contact。
      merged-from: [] # 如果是合并产生的contact，这里记录合并前的cid

  as-contact-of: ['uid-of-zhangsan', 'uid-of-zhaowu'] # 当前用户都出现为谁的联系人
#-------- strangers --------#
# 在当前用户的通信历史中出现过，但又不是用户的联系人的phone、email等等，系统为这些人生成（is-register = false）的用户，并记录它们与用户的关系。
  contacted-strangers: ['uid-of-stranger-1', 'uid-of-stranger-2'] # 用户联系过的strangers。
  contacted-by-strangers: ['uid-of-stranger-3', 'uid-of-stranger-2'] # 联系过用户的strangers，stranger-2即联系过当前用户，也被当前用户联系过。
