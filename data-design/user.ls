user = # yoyo server端数据
  uid: "xxxx" # 注册用户之后将存在, 对于尚未注册，而仅仅是通过他人通讯录识别的user，为null。
  name: "张三"
  avatar: "default-avatar-id" # 默认为系统计算出的avatar，用户上传可修改。今后可拓展为avatars 和 current avatar
  current-phone: "3456789" # 今后可拓展为phones和current phone
  sn:
    * sn-name: "豆瓣"
      account-name: "张三豆"
      api-key: "xxxx" # 服务端授权后得到的key，用以从SN获取信息。
    ...
  tags: ["程序员"]
  has-contacts: 
    * cid: []
    ...
  as-contacts: 
    * cid: []
    ...
