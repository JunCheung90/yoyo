contact = # yoyo server端数据，在计算得到user-contacts时，contact中的数据将覆盖或整合user中同类数据
  cid: null # 注册用户之后将存在
#============= 下面数据和user的类似 ================
  name: "李四" 
  avatar: null
  current-phone: "3456789"
  sn:
    * sn-name: "豆瓣"
      account-name: "张三豆"
    ...
  tags: ["同事"]
#============= 上面数据和user的类似 ================

  belongs-to: "xxxx" # has-contacts的另一端
  act-by: "xxxx" # as-contacts的另一端