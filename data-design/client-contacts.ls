user-contacts = # yoyo mobile phone 端的数据，server端有同样（版本可能不同）的数据
  yoyo-lv: "uid-lv-xxxx" # yoyo local version，注册时产生，xxxx为流水号
  yoyo-sv: "uid-sv-xxxx" # yoyo server version，注册时产生，xxxx为流水号
  uid: null # 注册用户之后将存在
  name: "张三"
  avatar: null
  current-phone: "3456789"
  sn:
    * sn-name: "豆瓣"
      account-name: "张三豆"
    ...
  contacts: 
    * cid: null # 新建联系人之后将存在
      name: "李四"
      avatar: null
      current-phone: "12345678"
      tags: ['朋友', '同事']
    * cid: null
      name: "赵小五"
      avatar: null
      current-phone: "23456789"
