# 返回客户端的接口格式, 数据样例见client-sn-update-sample.json
# 请求参数格式（？uid & since-id-configs & count = 20）后二者为备选
# count为每种平台上返回更新的数量，默认为10
# since-id-configs =  
#   * type: weibo
#     since-id: 130
client-sn-update = 
  content:
    * type: 'weibo'
      since-id: 131 # 最后一条微博的id
      updates: ['json_result1', 'json_result2']
    ...
  count: 40 # 所有平台共返回多少条  
      
