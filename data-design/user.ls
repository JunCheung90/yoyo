user = # yoyo server端数据
  #----------- profile ----------#
  uid: 'xxxx' # 注册用户之后将存在, 对于尚未注册，而仅仅是通过他人通讯录识别的user，为null。
  is-person: true # true | false 对于单位用户（电话）来说为false
  name: '张三'
  nicknames: ['小张', '小三'] # 从他人通信录里面给当前用户的名称中获取。
  avatars: ['s-aid-1', 's-aid-2', 'u-aid-1', 'u-aid-2'] # avatar的id全局唯一，有系统计算给出的（s）和用户上传的（u）
  current-avatar: 's-aid-2'
  phones: # 记录用户使用（过）的电话号码。
    * phone-number: '3456789'
      is-active: true
      start-using-time: '2012-11-05'
    * phone-number: '1'
      is-active: false
      start-using-time: '2010-01-01'
      end-using-time: '2012-11-01' # 更换或被系统发现用户停用电话的时间（其它用户用了这个号码）
  emails:
    'zhangsan@fake.com'
    ...      
  ims: # 多个IM
    * type: 'QQ'
      account: '111111'
      is-active: true
      api-key: 'qq可能给出的api key' #所有api-key都不会给回手机端，仅仅是服务端用来获取用户update的信息，将来有可能会从user中移出去。
    * type: 'AOL'
      account: '222222'
      is-active: true
      api-key: 'AOL可能给出的api key'
  sns:
    * type: '豆瓣'
      account-name: '张三豆'
      account-id: '1213213' # acount-name和account-id两者必须有一个
      api-key: 'xxxx' # 社交平台端授权后得到的key，用以从SN获取信息，由手机客户端上传
    ...
  addresses:
    '广州 大学城 中山大学 至善园 307'
    ...
  tags: ['程序员'] # 用户给自己的标签，或者系统发掘出用户的特征。
  #----------- status ----------#
  is-updated: false # 用户的数据是否发生了更新，如果为true，需要重新评估mergences。
  is-registered: true
  last-modified-date: '2013-01-09'
  merged-to: null 
  merged-from: [] # 这里有可能是多个merge后的结果, 包括了所有信息的最初来源。如果A merge到了B，B又merge到了C，则在C的merged-from里面有A也有B。但是，A的merge-to仍然记录为B。
  pending-merges: # 等待系统在未来确定，或者由后台人工accept，或者reject的pending merges。yoyo对于User只会pending merge，已经存在的User其最终Merge一定是由人来决定的。
    * pending-merge-to: null# 该user推荐合并到的user
      pending-merge-from: null # 该user推荐合并的user，每次pending都是两个user的合并。
      is-accepted: null # null undefiend 还没有决策 | true | false TODO：这里是否多余，是不是accepted就取消，rejected就记录到not-merge-with？
    ...
  not-merge-with: [] # 记录拒绝合并的情况，避免多次推荐
  #----------- relations ----------#
  contacts: # 当前用户的联系人
    * cid: 'owner-uid-c-timestamp_of_add-seqno'
      act-by-user: 'uid_lisi'
      names: ['李小四']
      rank-score: 399 # yoyo服务器计算得出的联系人推荐排名分数，越大排名越靠前
      avatars: ['s-aid', 'u-aid-1', 'u-aid-2'] # s-aid是系统根据通信时间计算出的avatar，u-aid是用户给这个联系人设定的。在用户手机上显示时，this.u-aid > act-by-user.current-avatar > this.s-aid
      phones: ['123456']
      emails: ['lisi@fake.com']
      ims: 
        * type: 'QQ'
          account: 'lisi111'
        ...
      sns: [] # 社交网络的列表
      tags: [] # 这些是当前用户给这个联系人定义的标签，说明了他们的关系
      ...
      #-------- merge --------#
      # 用户的merge总是由后端执行，如果不确定则为pending，让后台管理员来人工处理。
      merged-to: null # 非null时，当前联系人已经合并给了该字段指向的Contact（所有信息都加过去了）
      merged-from: [] # 非空时，当前联系人包括了这里所有Contact的信息
      pending-merges: # 等待用户accept，或者reject的pending merges
        * pending-merge-to: null# 该Contact推荐合并到的contact
          pending-merge-from: null # 该Contact推荐合并contact，每次pending都是两个contact的合并。
          is-accepted: null # null undefiend 为用户还没有决策 | true | false
        ...
      not-merge-with: [] # 记录用户拒绝合并的情况，避免多次向用户推荐

  as-contact-of: ['uid-of-zhangsan', 'uid-of-zhaowu'] # 当前用户都出现为谁的联系人
#-------- strangers --------#
# 在当前用户的通信历史中出现过，但又不是用户的联系人的phone、email等等，系统为这些人生成（is-register = false）的用户，并记录它们与用户的关系。
  contacted-strangers: ['uid-of-stranger-1', 'uid-of-stranger-2'] # 用户联系过的strangers。
  contacted-by-strangers: ['uid-of-stranger-3', 'uid-of-stranger-2'] # 联系过用户的strangers，stranger-2即联系过当前用户，也被当前用户联系过。
#-------- interesting-info --------#
  interesting-infos:
    * iiid: 'uid-ii-timestamp_of_add-seqno' 
      type: 'most-calling-out-time' # ii的类别，可以挖掘多种不同有趣信息给回客户端
      # info这部分的内容，可以不存在user里面，单独存储type和其对应的info，这里仅仅存type和data就可以了。但是，
      info: '#{data.related-contact.name}坑电话费啊, #{data.time-frame}我竟然打了#{calling-out-times}电话给他，\
            说了#{data.calling-out-amount-time}，至少花了我#{data.fee}。这笔帐不能不算！<a href=#{data.related-contact.cid}>#{data.related-contact.name}</a>\
            还我小钱钱来！'
      data: # 有关ii的数据，不同type可能不同。
        related-contact
          name: '张三'
          cid: 'cid-of-zhangsan'
        time-frame:
          start-time: '2012-12-01 08-10-11'
          end-time: '2013-01-01 23-10-11'
        calling-out-times: 210 # 210次
        calling-out-amount-time: '310 m' # 310分钟
        fee
      created-time: '2013-01-01 23-10-11'

require! fs

# 下面部分用来生成json数据
(err) <-! fs.writeFile 'zhangsan.json', JSON.stringify(user, null, '\t')
throw new Error err if err
console.log "user data have been exported to zhangsan.json"