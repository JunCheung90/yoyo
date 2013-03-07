module.exports <<< 
	update-amount: 100	# 一次抓取的最大更新条数（每个平台）
	batch-limit: 100	# 并发处理的数量
	max-update-amount: 10	# 返回客户端的最大更新条数（每个平台）
	update-interval: 1000*60 # 抓取sn平台更新的频率，1分钟一次。新浪的访问频率限制http://open.weibo.com/wiki/Rate-limiting#.E6.9C.AA.E9.80.9A.E8.BF.87.E5.AE.A1.E6.A0.B8.E5.BA.94.E7.94.A8.E7.9A.84.E6.B5.8B.E8.AF.95.E8.B4.A6.E5.8F.B7.E9.99.90.E5.88.B6
	# 默认返回所有条目
	since-id-default-configs: [
		{
			type: 'weibo'
			since-id: 0
		}
	]